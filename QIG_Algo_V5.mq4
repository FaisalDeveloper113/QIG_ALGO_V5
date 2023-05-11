//+------------------------------------------------------------------+
//|                                               New_Rsi_Expert.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MaxOrders 200

struct Order_Struct
  {
   int               Ticket;
   ENUM_ORDER_TYPE   Order_Type;
   double            OpenPrice;
   datetime          OpenTime;
   bool              is_Tp1_Hit;
   bool              is_Tp2_Hit;
   double            initial_balance;
   int               hedge_ticket;
   double            hedge_price;
   double            hedge_sl;
   double            hedge_lot;
   int               hedge_count;
   int               hedge_candle_count;
   string            zone;
                     Order_Struct()
     {
      OpenPrice = -1;
      hedge_ticket = -1;
     }
  };
Order_Struct Orders[MaxOrders];

enum strategy_tpe
  {
   Both = 0, //Both
   Sell = 1, //Sell
   Buy = 2  // Buy
  };
input    string               S_20_20              =  "<><><><><><>SUPER TREND SETTINGS<><><><><><>"; //_
input    ENUM_TIMEFRAMES      super_MA_TimeFrame   =  PERIOD_H4;     // MA TimeFrame
input    int                  super_ma_period      =  25;            // SuperTrend MA Period
input    ENUM_MA_METHOD       super_ma_mode        =  MODE_SMA;      // SuperTrend MA Mode
input    ENUM_APPLIED_PRICE   super_ma_price       =  PRICE_CLOSE;   // SuperTrend MA Applied Price
input    int                  super_ma_shift       =  1;             // SuperTrend MA Shift
input    int                  angle_candle_shift   = 3;              // Calculate Angle on Last x Candles
input    double               angle_threshold      = 20;            // MA Angle Thresh hold (Degree)
input    color                Aggressive_color     = clrGreenYellow;  // Aggressive Trend Color
input    color                Conservative_color   = clrBlueViolet;     // Conservative Trend Color
input    string               S_O_O                =  "<><><><><><>EXPERT SETTINGS<><><><><><>"; //_
input    strategy_tpe         Strategy_Type        =  Both;          // Strategy Type
input    ENUM_TIMEFRAMES      Time_Frame           =  PERIOD_M15;    // Expert TimeFrame
input    int                  Magic_Number         =  113;           // Expert Magic Number



input string               S_12_12        =  "**SCALLING SETTINGS**"; //_
input bool                 Enable_Scaling =  false;          // Enable Scaling
input double               ScalingBalance =  15000;          // Set Scaling Balance
input double               ScalingLot     =  0.06;           // Set Scaling Lot
input string               S_15_15        =  "**TIME SETTINGS**"; //_
input bool                 EnableTimeFilter = false;                  // Enable Time Filter
input string               Start_Time     =  "09:30";                // Trade Start Time
input string               End_Time       =  "21:30";                // Trade End Time


input string               S_13_13        =  "<><><><><><>AGGRESSIVE BUY SETTINGS<><><><><><>"; //_
input double               Lot_Size       =  0.03;          // Set Lot Size Aggressive
input string               S_N_N          =  "**TP1 SETTINGS**"; //_
input int                  Tp1            =  300;            // Aggressive TakeProfit 1
input double               Tp1_Close_Lot  =  0.01;           // Aggressive TakeProfit 1 Lot Close
input int                  offset_tp1     =  300;             // Aggressive StopLoss Offset Tp1 (0 = No SL Update)
input string               S_M_M          =  "**TP2 SETTINGS**"; //_
input int                  Tp2            =  600;           // Aggressive TakeProfit 2
input double               Tp2_Close_Lot  =  0.01;           // Aggressive TakeProfit 2 Lot Close
input int                  offset_tp2     =  300;             // Aggressive StopLoss Offset Tp2 (0 = No SL Update)
input string               S_L_L          =  "**TP3 SETTINGS**"; //_
input int                  Tp3            =  1200;           // Aggressive TakeProfit 3

input string               S_33_33                    =  "<><><><><><>CONSERVATIVE BUY SETTINGS<><><><><><>"; //_
input double               ConservativeLot_Size       =  0.04;          // Set Lot Size Conservative
input string               S_NN_NN                      =  "**TP1 SETTINGS**"; //_
input int                  ConservativeTp1            =  650;            // Conservative TakeProfit 1
input double               ConservativeTp1_Close_Lot  =  0.02;           // Conservative TakeProfit 1 Lot Close
input int                  Conservativeoffset_tp1     =  650;             // Conservative StopLoss Offset Tp1 (0 = No SL Update)
input string               S_MM_MM                    =  "**TP2 SETTINGS**"; //_
input int                  ConservativeTp2            =  1550;           // Conservative TakeProfit 2
input double               ConservativeTp2_Close_Lot  =  0.01;           // Conservative TakeProfit 2 Lot Close
input int                  Conservativeoffset_tp2     =  300;             // Conservative StopLoss Offset Tp2 (0 = No SL Update)
input string               S_LL_LL                    =  "**TP3 SETTINGS**"; //_
input int                  ConservativeTp3            =  2600;           // Conservative TakeProfit 3


input string               S_6_6          =  "<><><><><><>HEDGE SETTINGS<><><><><><>"; //_
input bool                 Enable_Hedge   =  true;             // Enable Hedge Trade
input int                  Hedge_Pips_Buy =  20000;              // BUY Hedge Trade Pips Difference
input double               Hegde_SL_Buy       =  650;               // BUY Hedge StopLoss pips
input int                  Hedge_Pips_Sell=  20000;              // SELL Hedge Trade Pips Difference
input double               Hegde_SL_Sell       =  650;               // SELL Hedge StopLoss pips
//    double               DrawDown       =  15;               // Open Hedge Sell at % DrawDown
input bool                 Close_Max_Hits =  false;             // Enable Emergency Close Order When Max Hits Reached
input int                  Total_Hits     =  10;               // Total Sell hedge Hits
input bool                 CloseOrders    =  false;             // Enable Emergency Close Orders on desired % Loss
input double               Hedge_Loss     =  30;               // Desired % Loss
input bool                 Close_Orders_hedge = false;         // Close Order After X Candles After Hedge Trade is Active
input int                  Hedge_CandlesClose  =  100;              // Hedge Trades Activated Close Candles
input string               S_7_7          =  "<><><><><><>LINES SETTINGS<><><><><><>"; //_
input color                buy_start_line = clrYellowGreen; // Order Start Line
input color                buy_expiry_line = clrRed;        //Order Expiry Lineinput
input color                buy_trend_line_color = clrGreen; // Buy Trend Line Color
input color                Sell_trend_line_color = clrOrangeRed; // Sell Trend Line Color
input color                buy_sl_clr     =  clrGreen;      // Buy Trade StopLoss Line Color
input color                hedge_sl_clr   =  clrBlue;       // Hedge Trade StopLoss Line Color
input color                hedge_entry_clr = clrRed;        // Hedge Trade Entry Line Color
input int                  Line_Width     =  2;             // Set Line Width
input string               S_1_1          =  "<><><><><><>RSI SETTINGS<><><><><><>"; //_
input int                  Rsi_Period     =  13;            // RSI Period
input ENUM_APPLIED_PRICE   Rsi_Price      =  PRICE_CLOSE;   // RSI Applied Price
input int                   Rsi_shift      =  1;             // RSI Shift
input double               RsiCrossBelowLevelBuy  =  27.5;     // RSI Cross Below Buy Conservative
input double               RsiCrossAboveLevelBuy  =  33;       // RSI Cross Above Buy Conservative
input double               RsiCrossBelowLevelSell  =  67;     // RSI Cross Below Sell Conservative
input double               RsiCrossAboveLevelSell  =  73;       // RSI Cross Above Sell Conservative
input double               RsiCrossBelowLevelBuyAggressives  =  50;     // RSI Cross Below Buy Aggressive
input double               RsiCrossAboveLevelBuyAggressives  =  55;       // RSI Cross Above Buy

input double               RsiCrossAboveLevelSellAggressives  =  50;       // RSI Cross Above Sell Aggressives
input double               RsiCrossBelowLevelSellAggressives  =  45;     // RSI Cross Below Sell Aggressive
input string               S_2_2          =  "<><><><><><>FAST MA SETTINGS<><><><><><>"; //_
input ENUM_TIMEFRAMES      MA_TimeFrame   =  PERIOD_H4;     // MA TimeFrame
input int                  Fast_ma_period =  13;            // Fast MA Period
input ENUM_MA_METHOD       Fast_ma_mode   =  MODE_EMA;      // Fast MA Mode
input ENUM_APPLIED_PRICE   Fast_ma_price  =  PRICE_CLOSE;   // Fast MA Applied Price
input int                  Fast_ma_shift  =  1;             // Fast MA Shift
input string               S_3_3          =  "<><><><><><>SLOW MA SETTINGS<><><><><><>"; //_
input int                  Slow_ma_period =  21;            // Slow MA Period
input ENUM_MA_METHOD       Slow_ma_mode   =  MODE_SMA;      // Slow MA Mode
input ENUM_APPLIED_PRICE   Slow_ma_price  =  PRICE_CLOSE;   // Slow Ma Applied Price
input int                  Slow_ma_shift  =  1;             // Slow MA Shift

input string               S_Q_Q                =  "<><><><><><>AGGRESSIVE SELL SETTINGS<><><><><><>"; //_
input double               Lot_Size_Sell        =  0.03;          // Set Lot Size Aggressive
input string               S_S_S                =  "*TP1 SETTINGS*"; //_
input int                  Tp1_Sell             =  300;            // Aggressive TakeProfit 1 SELL
input double               Tp1_Close_Lot_Sell   =  0.01;           // Aggressive TakeProfit 1 Lot Close SELL
input int                   offset_tp1_Sell     =  300;             // Aggressive StopLoss Offset Tp1 SELL (0 = No SL Update)
input string               S_Z_Z                =  "*TP2 SETTINGS*"; //_
input int                  Tp2_Sell             =  600;           // Aggressive TakeProfit 2 SELL
input double               Tp2_Close_Lot_Sell   =  0.01;           // Aggressive TakeProfit 2 Lot Close SELL
input int                  offset_tp2_Sell      =  300;             // Aggressive StopLoss Offset Tp2 SELL (0 = No SL Update)
input string               S_D_D                =  "*TP3 SETTINGS*"; //_
input int                  Tp3_Sell             =  1200;           // Aggressive TakeProfit 3 SELL

input string               S_QO_QO                          =  "<><><><><><>CONSERVATIVE SELL SETTINGS<><><><><><>"; //_
input double               ConservativeLot_Size_Sell        =  0.04;          // Set Lot Size Conservative
input string               S_SS_SS                          =  "**TP1 SETTINGS**"; //_
input int                  ConservativeTp1_Sell             =  650;            // Conservative TakeProfit 1 SELL
input double               ConservativeTp1_Close_Lot_Sell   =  0.02;           // Conservative TakeProfit 1 Lot Close SELL
input int                  Conservativeoffset_tp1_Sell      =  650;             // Conservative StopLoss Offset Tp1 SELL (0 = No SL Update)
input string               S_ZZ_ZZ                          =  "**TP2 SETTINGS**"; //_
input int                  ConservativeTp2_Sell             =  1550;           // Conservative TakeProfit 2 SELL
input double               ConservativeTp2_Close_Lot_Sell   =  0.01;           // Conservative TakeProfit 2 Lot Close SELL
input int                  Conservativeoffset_tp2_Sell      =  300;             // Conservative StopLoss Offset Tp2 SELL (0 = No SL Update)
input string               S_DD_DD                          =  "**TP3 SETTINGS**"; //_
input int                  ConservativeTp3_Sell             =  2600;           // Conservative TakeProfit 3 SELL

string vLineBuy = "VLineBuy";
bool did_rsi_crossed_below_buy = false;
bool did_rsi_crossed_above_buy = false;
string hedge_entry_line = "hedge_entry_line";
string hedge_sl_line = "hedge_sl_line";
string buy_sl_line = "buy_sl_line";
string buy_expire_line = "buy_expire_line";
string buy_starts_line = "buy_start_line";
bool is_buy_condition_met = false;
datetime buy_expiry_time = 0;

string vLineSell = "VLineSell";
bool did_rsi_crossed_below_sell = false;
bool did_rsi_crossed_above_sell = false;
bool is_sell_condition_met = false;
string sell_expire_line = "buy_expire_line";
string sell_starts_line = "buy_start_line";
datetime sell_expiry_time = 0;
string hedge_entry_line_sel = "hedge_entry_line";
string hedge_sl_line_sell = "hedge_sl_line";
string sell_sl_line = "buy_sl_line";


string aggressive_trend = "aggressive_trend";
string conservative_trend = "conservative_trend";


// Scaling Variables
double newScalingBuyLot;
double newScalingBuyTp1Lot;
double newScalingBuyTp2Lot;

double newScalingSellLot;
double newScalingSellTp1Lot;
double newScalingSellTp2Lot;

double chart_min_price = 0;
double chart_max_price = 0;
//datetime expiration_date = D'2023.05.05 00:00:00';
double EMA_Angle_Value = 0;
string Zone;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentTime = iTime(Symbol(), PERIOD_M1,0);
   /*
      if(currentTime >= expiration_date)
        {
        }
   */

   Update_Super_Trend_Blocks_price();
//---
   find_partial_closed_order();
   UpdateHedgeOrder();
   Update_Orders_Structure(); // Update the Order Structre if all orders are closed
   Check_Tp1_Hit(); // Do BreakEven Order After Tp1 hit
   Check_Tp2_Hit(); // Update StopLoss after Tp2 Hit
   if(Enable_Hedge)
     {
      take_hedge_trade();  // Take Hedge Tarde
      if(CloseOrders)
         close_on_drawdown();
     }

   if(Enable_Scaling)
      calculate_new_scaling_lot();
//---
   if(isNewBar())
     {
      EMA_Angle_Value = EMA_Angle();
      if(EMA_Angle_Value > angle_threshold || (EMA_Angle_Value < (-1 * angle_threshold)))
        {
         Zone = "AGGRESSIVE";
         create_super_Trend_Blocks(true);
        }
      else
        {
         Zone = "CONSERVATIVE";
         create_super_Trend_Blocks(false);
        }


      datetime TardeStartTime = StringToTime(Start_Time);
      datetime TradeEndTime = StringToTime(End_Time);
      datetime CurrentCandleTime = iTime(Symbol(), Time_Frame, 0);
      Print_Order_Information();


      if(Close_Orders_hedge)
         Update_Hedge_Order_Candle_Count();

      if(Is_FastMa_Greater_Than_SlowMA())
        {
         Comment("BULLISH \n"+Zone+"\nAngle: "+ DoubleToString(EMA_Angle_Value,2));
         did_rsi_crossed_below_sell = false;
         did_rsi_crossed_above_sell = false;
         is_sell_condition_met = false;

         if(Strategy_Type == Both || Strategy_Type == Buy)
           {
            Create_VLine(OP_BUY);
            if((CurrentCandleTime >= TardeStartTime && CurrentCandleTime <= TradeEndTime && EnableTimeFilter) || !EnableTimeFilter)
              {
               Print("Inside Trade Time Buy --> Start Time: ", TardeStartTime, " EndTime: ", TradeEndTime, "CurrentTime: ", CurrentCandleTime);
               if(!is_buy_condition_met && check_orders_total(OP_BUY) == 0)
                 {
                  if(Rsi_Crossed_Below_buy(Zone) && !did_rsi_crossed_below_buy)
                    {
                     did_rsi_crossed_below_buy = true;
                     Print("Dipped Below Buy: ", iTime(Symbol(), PERIOD_CURRENT, 0));
                     Print("RSI: ", Get_Rsi_Value(), " Zone: ", Zone);
                    }
                  if(Rsi_Crossed_Above_Buy(Zone) && did_rsi_crossed_below_buy)
                    {
                     did_rsi_crossed_above_buy = true;
                     Print("Dipped Above Buy: ", iTime(Symbol(), PERIOD_CURRENT, 0));
                     Print("RSI: ", Get_Rsi_Value(), " Zone: ", Zone);
                    }
                 }

               // Check all trade conditions
               if(did_rsi_crossed_above_buy && did_rsi_crossed_below_buy)
                 {
                  Print("Order Need to be  Placed");
                  Print("Live Order Total: ", check_orders_total(OP_BUY));
                  Print("Structure Order Total: ", Total_Running_Orders(OP_BUY));
                  if(check_orders_total(OP_BUY) == 0 && Total_Running_Orders(OP_BUY) == 0)  // 2 Extra Orders Total Check
                    {
                     datetime current_candle_Time = iTime(Symbol(), Time_Frame, 0);

                     Print("Wait for the volume to go up above level until : ", buy_expiry_time);
                     create_buy_expiry_line(buy_expiry_time, OP_BUY);
                     double Tp3Pips = 0;
                     double Lot = 0;
                     if(Zone == "AGGRESSIVE")
                       {
                        Tp3Pips =Tp3;
                        Lot = Lot_Size;
                       }
                     else
                       {
                        Tp3Pips =ConservativeTp3;
                        Lot = ConservativeLot_Size;
                       }

                     double lotSize = Lot_Size;
                     double tp3 = Ask + Tp3Pips * Point * 10;
                     Print("Lets Place BUY");
                     int ticket = Place_Order(Magic_Number,OP_BUY, Lot, 0, tp3);
                     if(ticket != -1)
                       {
                        datetime current_time = iTime(Symbol(), PERIOD_CURRENT, 0);
                        if(Store_Order(OP_BUY,Ask,current_time,ticket,false,false, -1, -1, -1, -1, 0, AccountBalance(),Zone))
                          {
                           did_rsi_crossed_above_buy = false;
                           did_rsi_crossed_below_buy = false;

                           // Extra
                           Print("Trade Is Taken  and values are refreshed --> Below: ", did_rsi_crossed_below_buy, " Above: ",did_rsi_crossed_above_buy);
                          }
                       }
                    }
                 }
              }
            else
              {
               Print("Outside Trade Time Buy --> Start Time: ", TardeStartTime, " EndTime: ", TradeEndTime, "CurrentTime: ", CurrentCandleTime);
              }
           }
        }
      else
        {
         Comment("BEARISH \n"+Zone+"\nAngle: "+ DoubleToString(EMA_Angle_Value,2));
         did_rsi_crossed_above_buy = false;
         did_rsi_crossed_below_buy = false;
         if(Strategy_Type == Both || Strategy_Type == Sell)
           {
            Create_VLine(OP_SELL);

            if((CurrentCandleTime >= TardeStartTime && CurrentCandleTime <= TradeEndTime && EnableTimeFilter) || !EnableTimeFilter)
              {
               Print("Inside Trade Time Sell --> Start Time: ", TardeStartTime, " EndTime: ", TradeEndTime, "CurrentTime: ", CurrentCandleTime);
               if(!is_sell_condition_met && check_orders_total(OP_SELL) == 0)
                 {
                  if(Rsi_Crossed_Above_Sell(Zone) && !did_rsi_crossed_above_sell)
                    {
                     did_rsi_crossed_above_sell = true;
                     Print("Dipped Above Sell: ", iTime(Symbol(), PERIOD_CURRENT, 0));
                     Print("RSI: ", Get_Rsi_Value(), " Zone: ", Zone);
                    }
                  if(Rsi_Crossed_Below_Sell(Zone) && did_rsi_crossed_above_sell)
                    {
                     did_rsi_crossed_below_sell = true;
                     Print("Dipped Below Sell: ", iTime(Symbol(), PERIOD_CURRENT, 0));
                     Print("RSI: ", Get_Rsi_Value(), " Zone: ", Zone);
                    }
                 }

               // Check all trade conditions
               if(did_rsi_crossed_above_sell && did_rsi_crossed_below_sell)
                 {
                  Print("Order Need to be  Placed");
                  Print("Live Order Total: ", check_orders_total(OP_SELL));
                  Print("Structure Order Total: ", Total_Running_Orders(OP_SELL));
                  if(check_orders_total(OP_SELL) == 0 && Total_Running_Orders(OP_SELL) == 0)  // 2 Extra Orders Total Check
                    {
                     datetime current_candle_Time = iTime(Symbol(), Time_Frame, 0);

                     Print("Wait for the volume to go up above level until : ", buy_expiry_time);
                     create_buy_expiry_line(sell_expiry_time, OP_SELL);
                     double Tp3Pips = 0;
                     double Lot = 0;
                     if(Zone == "AGGRESSIVE")
                       {
                        Tp3Pips =Tp3_Sell;
                        Lot = Lot_Size_Sell;
                       }
                     else
                       {
                        Tp3Pips =ConservativeTp3_Sell;
                        Lot = ConservativeLot_Size_Sell;
                       }
                     double tp3 = Bid - Tp3Pips * Point * 10;
                     int ticket = Place_Order(Magic_Number,OP_SELL, Lot, 0, tp3);
                     if(ticket != -1)
                       {
                        datetime current_time = iTime(Symbol(), PERIOD_CURRENT, 0);
                        Print("Lets Place SELL");
                        if(Store_Order(OP_SELL,Bid,current_time,ticket,false,false, -1, -1, -1, -1, 0, AccountBalance(),Zone))
                          {
                           did_rsi_crossed_above_sell = false;
                           did_rsi_crossed_below_sell = false;

                           // Extra
                           Print("Trade Is Taken  and values are refreshed --> Below: ", did_rsi_crossed_below_sell, " Above: ",did_rsi_crossed_above_sell);
                          }
                       }
                    }
                 }
              }
            else
              {
               Print("Outside Trade Time Sell --> Start Time: ", TardeStartTime, " EndTime: ", TradeEndTime, "CurrentTime: ", CurrentCandleTime);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateHedgeOrder()
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].Ticket != -1 && Orders[i].hedge_ticket != -1)
        {
         if(OrderSelect(Orders[i].Ticket,SELECT_BY_TICKET))
           {
            double base_order_lot = OrderLots();
            int base_order_ticket = OrderTicket();
            ENUM_ORDER_TYPE base_order_type = (ENUM_ORDER_TYPE)OrderType();
            if(OrderSelect(Orders[i].hedge_ticket, SELECT_BY_TICKET))
              {
               double hedge_lot = OrderLots();
               if(base_order_lot != hedge_lot)
                 {
                  if(OrderDelete(OrderTicket(), clrRed))
                    {
                     if(base_order_type == OP_BUY)
                       {
                        int new_hedge_ticket = Place_Order_Hedge(Magic_Number,OP_SELLSTOP, Orders[i].hedge_price, base_order_lot, Orders[i].hedge_sl, 0);
                        if(new_hedge_ticket != -1)
                          {
                           Orders[i].hedge_ticket = new_hedge_ticket;
                          }
                       }
                     if(base_order_type == OP_SELL)
                       {
                        int new_hedge_ticket = Place_Order_Hedge(Magic_Number,OP_BUYSTOP, Orders[i].hedge_price, base_order_lot, Orders[i].hedge_sl, 0);
                        if(new_hedge_ticket != -1)
                          {
                           Orders[i].hedge_ticket = new_hedge_ticket;
                          }
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool find_opposite_order_in_struct(int ticket, ENUM_ORDER_TYPE type)
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].Ticket != -1 && Orders[i].hedge_ticket == ticket && Orders[i].Order_Type != type)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int check_orders_total(ENUM_ORDER_TYPE type)
  {

   int orders_total = 0;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number)
           {
            if(OrderType() == type)
              {
               if(!find_opposite_order_in_struct(OrderTicket(), type))
                  orders_total++;
              }
           }
        }
     }
   return orders_total;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Get_Rsi_Value()
  {
   Print("RSI : ", NormalizeDouble(iRSI(Symbol(), Time_Frame, Rsi_Period,Rsi_Price,Rsi_shift),Digits));
   return NormalizeDouble(iRSI(Symbol(), Time_Frame, Rsi_Period,Rsi_Price,Rsi_shift),Digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Rsi_Crossed_Below_buy(string zone)
  {
   if(check_orders_total(OP_BUY) != 0)
      return false;
   double RsiDipBelowValue;
   if(zone == "AGGRESSIVE")
      RsiDipBelowValue = RsiCrossAboveLevelBuyAggressives;
   else
      RsiDipBelowValue = RsiCrossBelowLevelBuy;
   if(Get_Rsi_Value() < RsiDipBelowValue)
     {
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Rsi_Crossed_Below_Sell(string zone)
  {
   if(check_orders_total(OP_SELL) != 0)
      return false;
   double RsiCrossedBelowSell;
   if(zone == "AGGRESSIVE")
      RsiCrossedBelowSell = RsiCrossBelowLevelSellAggressives;
   else
      RsiCrossedBelowSell = RsiCrossBelowLevelSell;
   if(Get_Rsi_Value() < RsiCrossedBelowSell)
     {
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Rsi_Crossed_Above_Buy(string zone)
  {
   if(check_orders_total(OP_BUY) != 0)
      return false;
   double RsiCrossedAboveBuy;
   if(zone == "AGGRESSIVE")
      RsiCrossedAboveBuy = RsiCrossAboveLevelBuyAggressives;
   else
      RsiCrossedAboveBuy = RsiCrossAboveLevelBuy;
   if(Get_Rsi_Value() > RsiCrossedAboveBuy)
     {
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Rsi_Crossed_Above_Sell(string zone)
  {
   if(check_orders_total(OP_SELL) != 0)
      return false;
   double RsiCrossedAboveSell;
   if(zone == "AGGRESSIVE")
      RsiCrossedAboveSell = RsiCrossAboveLevelSellAggressives;
   else
      RsiCrossedAboveSell = RsiCrossAboveLevelSell;
   if(Get_Rsi_Value() > RsiCrossedAboveSell)
     {
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Get_Fast_MA_Value()
  {
   return NormalizeDouble(iMA(Symbol(), MA_TimeFrame, Fast_ma_period, 0, Fast_ma_mode, Fast_ma_price, Fast_ma_shift),Digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Get_Slow_MA_Value()
  {
   return NormalizeDouble(iMA(Symbol(), MA_TimeFrame, Slow_ma_period, 0, Slow_ma_mode, Slow_ma_price, Slow_ma_shift),Digits);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Is_FastMa_Greater_Than_SlowMA()
  {
   if(Get_Fast_MA_Value() > Get_Slow_MA_Value())
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
bool Create_VLine(ENUM_ORDER_TYPE type)
  {
   datetime Candle_Time = iTime(Symbol(), Time_Frame, 1);
   if(type == OP_BUY)
     {
      string objectName = vLineBuy + (string)Candle_Time;
      if(ObjectFind(objectName) == -1)
        {
         if(!ObjectCreate(0,objectName,OBJ_VLINE,0,iTime(Symbol(), Time_Frame, 0),0))
           {
            Print(__FUNCTION__,
                  ": failed to create a vertical line! Error code = ",GetLastError());
            return(false);
           }
         else
           {
            ObjectSetInteger(0,objectName,OBJPROP_COLOR,buy_trend_line_color);
            ObjectSetInteger(0,objectName,OBJPROP_STYLE,STYLE_DOT);
            ObjectSetInteger(0,objectName,OBJPROP_WIDTH,1);
            ObjectSetInteger(0,objectName,OBJPROP_BACK,true);
            return true;
           }
        }
     }
   if(type == OP_SELL)
     {
      string objectName = vLineSell + (string)Candle_Time;
      if(ObjectFind(objectName) == -1)
        {
         if(!ObjectCreate(0,objectName,OBJ_VLINE,0,iTime(Symbol(), Time_Frame, 0),0))
           {
            Print(__FUNCTION__,
                  ": failed to create a vertical line! Error code = ",GetLastError());
            return(false);
           }
         else
           {
            ObjectSetInteger(0,objectName,OBJPROP_COLOR,Sell_trend_line_color);
            ObjectSetInteger(0,objectName,OBJPROP_STYLE,STYLE_DOT);
            ObjectSetInteger(0,objectName,OBJPROP_WIDTH,1);
            ObjectSetInteger(0,objectName,OBJPROP_BACK,true);
            return true;
           }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool create_buy_expiry_line(datetime expiry_time, ENUM_ORDER_TYPE type)
  {

   datetime Candle_Time = iTime(Symbol(), Time_Frame, 0);
   string objectName =  buy_expire_line + (string)Candle_Time;
   if(ObjectFind(objectName) == -1)
     {
      if(!ObjectCreate(0,objectName,OBJ_VLINE,0,expiry_time,0))
        {
         Print(__FUNCTION__,
               ": failed to create a vertical line Buy Expiry Line! Error code = ",GetLastError());
         return(false);
        }
      else
        {
         ObjectSetInteger(0,objectName,OBJPROP_COLOR,buy_expiry_line);
         ObjectSetInteger(0,objectName,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,objectName,OBJPROP_WIDTH,2);
         ObjectSetInteger(0,objectName,OBJPROP_BACK,true);

         string newobjectName =  buy_starts_line + (string)Candle_Time;
         datetime time = iTime(Symbol(), Time_Frame, 0);
         if(ObjectFind(newobjectName) == -1)
           {
            if(!ObjectCreate(0,newobjectName,OBJ_VLINE,0,time,0))
              {
               Print(__FUNCTION__,
                     ": failed to create a vertical line Buy Start Line! Error code = ",GetLastError());
               return(false);
              }
            else
              {
               ObjectSetInteger(0,newobjectName,OBJPROP_COLOR,buy_start_line);
               ObjectSetInteger(0,newobjectName,OBJPROP_STYLE,STYLE_SOLID);
               ObjectSetInteger(0,newobjectName,OBJPROP_WIDTH,2);
               ObjectSetInteger(0,newobjectName,OBJPROP_BACK,true);
               return true;
              }
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
bool isNewBarSuperTrend()
  {
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(), super_MA_TimeFrame, SERIES_LASTBAR_DATE);
   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      Print("..... NEWBAR Super Trend ......", last_time);
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(), Time_Frame, SERIES_LASTBAR_DATE);
   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      Print("..... NEWBAR ......", last_time);
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
int Place_Order(int Magic,int Ordertype, double LotSize, double Stoploss, double Takeprofit)
  {
   if(Ordertype == OP_BUY)
     {
      int chk1 = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Stoploss, Takeprofit, "BUY RSI EXPERT V2", Magic, 0, clrBlue);
      if(chk1 < 0)
        {
         Print("OrderSend failed with error #", GetLastError());
         return -1;
        }
      else
        {
         Print("OrderSend placed successfully");
         return chk1;
        }
     }
   if(Ordertype == OP_SELL)
     {
      int chk1 = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Stoploss, Takeprofit, "SELL RSI EXPERT V2", Magic, 0, clrRed);
      if(chk1 < 0)
        {
         Print("OrderSend failed with error #", GetLastError());
         return -1;
        }
      else
        {
         Print("OrderSend placed successfully");
         return chk1;
        }
     }
   return -1;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Place_Order_Hedge(int Magic,int Ordertype, double price, double LotSize, double Stoploss, double Takeprofit)
  {
   if(Ordertype == OP_SELLSTOP)
     {
      int chk1 = OrderSend(Symbol(), OP_SELLSTOP, LotSize, price, 3, Stoploss, Takeprofit, "SELL HEDGE RSI V2", Magic, 0, clrRed);
      if(chk1 < 0)
        {
         Print("OrderSend failed with error #", GetLastError());
         return -1;
        }
      else
        {
         Print("OrderSend placed successfully");
         return chk1;
        }
     }
   if(Ordertype == OP_BUYSTOP)
     {
      int chk1 = OrderSend(Symbol(), OP_BUYSTOP, LotSize, price, 3, Stoploss, Takeprofit, "BUY HEDGE RSI V2", Magic, 0, clrBlue);
      if(chk1 < 0)
        {
         Print("OrderSend failed with error #", GetLastError());
         return -1;
        }
      else
        {
         Print("OrderSend placed successfully");
         return chk1;
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
/*
bool Is_Desired_Volume_Reached()
  {

   if(Get_Volume() > volumeLow)
     {
      Print("volume :", Get_Volume(), "Required Volume : ", volumeLow);
      return true;
     }
   else
      return false;
  }
  */
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Get_Volume()
  {
   long volume = iVolume(Symbol(), Time_Frame, 1);
   return volume;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool Store_Order(ENUM_ORDER_TYPE orderType, double price, datetime opentime, int ticket, bool is_Tp1_Hit, bool is_Tp2_Hit,
                 int hedgeTicket, double hedgeprice, double hedgesl, double hedgelot, int hedgecount, double balance, string zone)
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice == -1)
        {
         Orders[i].Order_Type = orderType;
         Orders[i].OpenPrice = price;
         Orders[i].OpenTime = opentime;
         Orders[i].Ticket = ticket;
         Orders[i].is_Tp1_Hit = is_Tp1_Hit;
         Orders[i].is_Tp2_Hit = is_Tp2_Hit;
         Orders[i].initial_balance = balance;
         Orders[i].hedge_ticket = hedgeTicket;
         Orders[i].hedge_price = hedgeprice;
         Orders[i].hedge_sl = -1;
         Orders[i].hedge_lot = -1;
         Orders[i].hedge_count = hedgecount;
         Orders[i].hedge_candle_count = 0;
         Orders[i].zone = zone;
         Print("Order Stored Successfully");
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Print_Order_Information()
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1)
        {
         Print("[",i,"] -->  OpenPrice : ", Orders[i].OpenPrice,
               " OrderType : ", Orders[i].Order_Type,
               " Ticket : ", Orders[i].Ticket,
               " Tp1 Hit : ", Orders[i].is_Tp1_Hit,
               " Tp2 Hit : ", Orders[i].is_Tp2_Hit,
               " Initial Balance : ", Orders[i].initial_balance,
               " Hedge Ticket : ", Orders[i].hedge_ticket,
               " Hedge Candles : ", Orders[i].hedge_candle_count,
               " Hedge Count : ", Orders[i].hedge_count,
               " Hedge SL : ", Orders[i].hedge_sl,
               " Hedge Lot : ", Orders[i].hedge_lot
              );
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Check_Tp1_Hit()
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1)
        {
         if(!Orders[i].is_Tp1_Hit)
           {
            if(OrderSelect(Orders[i].Ticket, SELECT_BY_TICKET))
              {
               if(OrderType() == OP_BUY)
                 {
                  double Tp1Pips = 0;
                  double Lot = 0;
                  if(Orders[i].zone == "AGGRESSIVE")
                    {
                     Tp1Pips = Tp1;
                     Lot = Tp1_Close_Lot;
                    }
                  else
                    {
                     Tp1Pips = ConservativeTp1;
                     Lot = ConservativeTp1_Close_Lot;
                    }
                  double Tp_Value = Orders[i].OpenPrice + (Tp1Pips * Point() * 10);
                  if(Bid > Tp_Value)
                    {
                     if(!OrderClose(Orders[i].Ticket,Lot,OrderClosePrice(),10,clrRed))
                       {
                        Print("Problem in Closing Tp1 : ", GetLastError());
                       }
                     else
                       {
                        Orders[i].is_Tp1_Hit = true;
                        Print("OrderTicket Before : ", Orders[i].Ticket);
                        find_partial_closed_order();
                        Print("OrderTicket After : ", Orders[i].Ticket);
                        Do_BreakEven(Orders[i].Ticket,Orders[i].zone);
                        Print("Update hedge Order");
                        UpdateHedgeOrder();
                       }
                    }
                 }
               if(OrderType() == OP_SELL)
                 {
                  double Tp1Pips = 0;
                  double Lot = 0;
                  if(Orders[i].zone == "AGGRESSIVE")
                    {
                     Tp1Pips = Tp1_Sell;
                     Lot = Tp1_Close_Lot_Sell;
                    }
                  else
                    {
                     Tp1Pips = ConservativeTp1_Sell;
                     Lot = ConservativeTp1_Close_Lot_Sell;
                    }
                  double Tp_Value = Orders[i].OpenPrice - (Tp1Pips * Point() * 10);
                  if(Ask < Tp_Value)
                    {
                     if(!OrderClose(Orders[i].Ticket,Lot,OrderClosePrice(),10,clrRed))
                       {
                        Print("Problem in Closing Tp1 : ", GetLastError());
                       }
                     else
                       {
                        Orders[i].is_Tp1_Hit = true;
                        Print("OrderTicket Before : ", Orders[i].Ticket);
                        find_partial_closed_order();
                        Print("OrderTicket After : ", Orders[i].Ticket);
                        Do_BreakEven(Orders[i].Ticket, Orders[i].zone);
                        Print("Update hedge Order");
                        UpdateHedgeOrder();
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void Do_BreakEven(int ticket, string zone)
  {
   Print("Do Breakeven");
   if(OrderSelect(ticket, SELECT_BY_TICKET))
     {
      if(OrderType() == OP_BUY && offset_tp1 > 0)
        {
         double OffsetTp1Pips = 0;
         double Tp1Pips = 0;
         if(zone == "AGGRESSIVE")
           {
            OffsetTp1Pips = offset_tp1;
            Tp1Pips = Tp1;
           }
         else
           {
            OffsetTp1Pips = Conservativeoffset_tp1;
            Tp1Pips = ConservativeTp1;
           }
         double TakeProfit_1_Value = OrderOpenPrice() + (Tp1Pips*Point() * 10);
         double stoploss = TakeProfit_1_Value - (OffsetTp1Pips*Point() * 10);
         stoploss = NormalizeDouble(stoploss,Digits());
         Print("Updated Tp1 StopLoss: ", TakeProfit_1_Value);
         bool res=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),10,clrRed);
         if(!res)
            Print("Error in OrderModify Breakeven. Error code=",GetLastError());
         else
           {
            Print("Order modified successfully.");
            create_order_sl_line(stoploss, OP_BUY);
           }
        }
      if(OrderType() == OP_SELL && offset_tp1_Sell > 0)
        {
         double OffsetTp1Pips = 0;
         double Tp1Pips = 0;
         if(zone == "AGGRESSIVE")
           {
            OffsetTp1Pips = offset_tp1_Sell;
            Tp1Pips = Tp1_Sell;
           }
         else
           {
            OffsetTp1Pips = Conservativeoffset_tp1_Sell;
            Tp1Pips = ConservativeTp1_Sell;
           }
         double TakeProfit_1_Value = OrderOpenPrice() - (Tp1Pips*Point() * 10);
         double stoploss = TakeProfit_1_Value + (Tp1Pips*Point() * 10);
         stoploss = NormalizeDouble(stoploss,Digits());
         Print("Updated Tp1 StopLoss: ", TakeProfit_1_Value);
         bool res=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),10,clrRed);
         if(!res)
            Print("Error in OrderModify Breakeven. Error code=",GetLastError());
         else
           {
            Print("Order modified successfully.");
            create_order_sl_line(stoploss, OP_SELL);
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Check_Tp2_Hit()
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1)
        {
         if(Orders[i].is_Tp1_Hit && !Orders[i].is_Tp2_Hit)
           {
            if(OrderSelect(Orders[i].Ticket, SELECT_BY_TICKET))
              {
               if(OrderType() == OP_BUY)
                 {
                  double Lot = 0;
                  double Tp2Pips = 0;
                  if(Orders[i].zone == "AGGRESSIVE")
                    {
                     Tp2Pips = Tp2;
                     Lot = Tp2_Close_Lot;
                    }
                  else
                    {
                     Tp2Pips = ConservativeTp2;
                     Lot = Tp2_Close_Lot_Sell;
                    }
                  double Tp_Value = Orders[i].OpenPrice + (Tp2Pips * Point() * 10);
                  if(Bid > Tp_Value)
                    {
                     if(!OrderClose(Orders[i].Ticket,Lot,OrderClosePrice(),10,clrGreen))
                       {
                        Print("Problem in Closing Tp2 : ", GetLastError());
                       }
                     else
                       {
                        Orders[i].is_Tp2_Hit = true;
                        Print("OrderTicket Before : ", Orders[i].Ticket);
                        find_partial_closed_order();
                        Print("OrderTicket Before : ", Orders[i].Ticket);
                        Do_BreakEven(Orders[i].Ticket, Orders[i].zone);
                        Update_StopLoss_After_Tp2(Orders[i].Ticket,Orders[i].zone);
                        Print("Update hedge Order");
                        UpdateHedgeOrder();
                       }
                    }
                 }
               if(OrderType() == OP_SELL)
                 {
                  double Tp2Pips = 0;
                  double Lot = 0;
                  if(Orders[i].zone == "AGGRESSIVE")
                    {
                     Tp2Pips = Tp2_Sell;
                     Lot = Tp2_Close_Lot_Sell;

                    }
                  else
                    {
                     Tp2Pips = ConservativeTp2_Sell;
                     Lot = ConservativeTp2_Close_Lot_Sell;
                    }
                  double Tp_Value = Orders[i].OpenPrice - (Tp2Pips * Point() * 10);
                  if(Ask < Tp_Value)
                    {
                     if(!OrderClose(Orders[i].Ticket,Lot,OrderClosePrice(),10,clrGreen))
                       {
                        Print("Problem in Closing Tp2 : ", GetLastError());
                       }
                     else
                       {
                        Orders[i].is_Tp2_Hit = true;
                        Print("OrderTicket Before : ", Orders[i].Ticket);
                        find_partial_closed_order();
                        Print("OrderTicket Before : ", Orders[i].Ticket);
                        Do_BreakEven(Orders[i].Ticket, Orders[i].zone);
                        Update_StopLoss_After_Tp2(Orders[i].Ticket,Orders[i].zone);
                        Print("Update hedge Order");
                        UpdateHedgeOrder();
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void Update_StopLoss_After_Tp2(int ticket, string zone)
  {
   if(OrderSelect(ticket, SELECT_BY_TICKET))
     {
      if(OrderType() == OP_BUY && offset_tp2 > 0)
        {
         double OffsetTp2Pips = 0;
         double Tp2Pips = 0;
         if(zone == "AGGRESSIVE")
           {
            OffsetTp2Pips = offset_tp2;
            Tp2Pips = Tp2;
           }
         else
           {
            OffsetTp2Pips = Conservativeoffset_tp2;
            Tp2Pips = ConservativeTp2;
           }
         double TakeProfit_2_Value = OrderOpenPrice() + (Tp2Pips * Point() * 10);
         double stoploss = TakeProfit_2_Value - OffsetTp2Pips*Point*10;
         stoploss = NormalizeDouble(stoploss,Digits());
         Print("Updated StopLoss after Tp2: ", stoploss);
         bool res=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),10,clrRed);
         if(!res)
            Print("Error in OrderModify TP2. Error code=",GetLastError());
         else
           {
            Print("Order modified successfully.");
            create_order_sl_line(stoploss, OP_BUY);
           }
        }
      if(OrderType() == OP_SELL && offset_tp2_Sell > 0)
        {
         double OffsetTp2Pips = 0;
         double Tp2Pips = 0;
         if(zone == "AGGRESSIVE")
           {
            OffsetTp2Pips = offset_tp2_Sell;
            Tp2Pips = Tp2_Sell;
           }
         else
           {
            OffsetTp2Pips = Conservativeoffset_tp2_Sell;
            Tp2Pips = ConservativeTp2_Sell;
           }
         double TakeProfit_2_Value = OrderOpenPrice() - (Tp2Pips * Point() * 10);
         double stoploss = TakeProfit_2_Value + Tp2Pips*Point*10;
         stoploss = NormalizeDouble(stoploss,Digits());
         Print("Updated StopLoss after Tp2: ", stoploss);
         bool res=OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),10,clrRed);
         if(!res)
            Print("Error in OrderModify TP2. Error code=",GetLastError());
         else
           {
            Print("Order modified successfully.");
            create_order_sl_line(stoploss,OP_SELL);
           }
        }
     }
  }
//+------------------------------------------------------------------+
void Update_Orders_Structure()
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1)
        {
         if(OrderSelect(Orders[i].Ticket, SELECT_BY_TICKET))
            if(OrderCloseTime() > 0)
              {
               Orders[i].OpenPrice = -1;
               ObjectDelete(hedge_entry_line);
               ObjectDelete(hedge_sl_line);
               ObjectDelete(buy_sl_line);
               if(OrderSelect(Orders[i].hedge_ticket, SELECT_BY_TICKET))
                 {
                  Print("Hedge Order Seletected Close Time: ", OrderCloseTime() < 0);
                  if(OrderCloseTime() <= 0)
                    {
                     Print("All Orders Orders are Closed ::: Removing from Struct");
                     if(OrderDelete(Orders[i].hedge_ticket,clrRed))
                       {
                        Orders[i].hedge_ticket = -1;
                       }
                    }
                  else
                     Orders[i].hedge_ticket = -1;
                 }
              }
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Update_Hedge_Order_Candle_Count()
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1)
        {
         if(OrderSelect(Orders[i].Ticket, SELECT_BY_TICKET))
           {
            if(OrderType() == OP_BUY && OrderCloseTime() <= 0)
              {
               int baseticket = OrderTicket();
               double baselots = OrderLots();
               if(OrderSelect(Orders[i].hedge_ticket, SELECT_BY_TICKET))
                 {
                  if(OrderType() == OP_SELL && OrderCloseTime() <= 0)
                    {
                     if(Orders[i].hedge_candle_count >= Hedge_CandlesClose)
                       {
                        if(OrderClose(baseticket,baselots,Bid,3,clrBlue))
                           Print("Base Buy Order Closed Hedge is Active for X Candles: ", Orders[i].hedge_candle_count);
                        if(OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed))
                           Print("Hedge Buy Order Closed Hedge is Active for X Candles: ", Orders[i].hedge_candle_count);
                        Orders[i].OpenPrice = -1;
                        Orders[i].Ticket = -1;
                        Orders[i].hedge_ticket = -1;
                        return;
                       }
                     Orders[i].hedge_candle_count = Orders[i].hedge_candle_count + 1;
                     Print("Buy Order hedge Candle Count Updated : ", Orders[i].hedge_candle_count);
                    }
                 }
              }
            if(OrderType() == OP_SELL && OrderCloseTime() <= 0)
              {
               int baseticket = OrderTicket();
               double baselots = OrderLots();
               if(OrderSelect(Orders[i].hedge_ticket, SELECT_BY_TICKET))
                 {
                  if(OrderType() == OP_BUY && OrderCloseTime() <= 0)
                    {
                     if(Orders[i].hedge_candle_count >= Hedge_CandlesClose)
                       {
                        if(OrderClose(baseticket,baselots,Ask,3,clrBlue))
                           Print("Base Buy Order Closed Hedge is Active for X Candles: ", Orders[i].hedge_candle_count);
                        if(OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed))
                           Print("Hedge Buy Order Closed Hedge is Active for X Candles: ", Orders[i].hedge_candle_count);
                        Orders[i].OpenPrice = -1;
                        Orders[i].Ticket = -1;
                        Orders[i].hedge_ticket = -1;
                        return;
                       }
                     Orders[i].hedge_candle_count = Orders[i].hedge_candle_count + 1;
                     Print("Sell Order hedge Candle Count Updated : ", Orders[i].hedge_candle_count);
                    }
                 }
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
void find_partial_closed_order()
  {
   for(int x=0; x<MaxOrders; x++)
     {
      if(Orders[x].OpenPrice != -1)
        {
         for(int i=0; i <= OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS))
              {
               if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number)
                 {
                  //Print("Order Ticket : ",OrderTicket()," Order Coment : ", OrderComment(), " Struct Ticket : ", Orders[x].Ticket);
                  if(StringFind(OrderComment(),(string)Orders[x].Ticket,0) != -1)
                    {
                     Print("Updating Struct Master Ticket : ", OrderTicket());
                     Orders[x].Ticket = OrderTicket();
                     break;
                    }
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
int Total_Running_Orders(ENUM_ORDER_TYPE type)
  {
   int count = 0;
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1 && Orders[i].Order_Type == type)
        {
         count++;
        }
     }
   return count;
  }
//+------------------------------------------------------------------+
void take_hedge_trade()
  {
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1 && Orders[i].hedge_ticket == -1)
        {
         if(Orders[i].Order_Type == OP_BUY)
           {
            double hedgeprice = Orders[i].OpenPrice - (Hedge_Pips_Buy * Point * 10);
            double StopLoss = hedgeprice + Hegde_SL_Buy * Point * 10;
            hedgeprice = NormalizeDouble(hedgeprice, Digits);
            StopLoss = NormalizeDouble(StopLoss, Digits);
            Print(" HedgePrice : ", hedgeprice, " StopLoss : ", StopLoss);
            double Lot = 0;
            if(Orders[i].zone == "AGGRESSIVE")
               Lot = Lot_Size;
            else
               Lot = ConservativeLot_Size;

            int ticket = Place_Order_Hedge(Magic_Number,OP_SELLSTOP,hedgeprice,Lot,StopLoss, 0);
            if(ticket != -1)
              {
               Print("Hedge Order Ticket  : ", ticket);
               Orders[i].hedge_ticket = ticket;
               Orders[i].hedge_price = hedgeprice;
               Orders[i].hedge_sl = StopLoss;
               Orders[i].hedge_lot = Lot;
               Orders[i].hedge_count = Orders[i].hedge_count + 1;
               create_hedge_entry_line(hedgeprice, OP_BUY);
               create_hedge_sl_line(StopLoss, OP_BUY);
              }
           }
         else
           {
            double hedgeprice = Orders[i].OpenPrice + (Hedge_Pips_Sell * Point * 10);
            double StopLoss = hedgeprice - Hegde_SL_Sell * Point * 10;
            hedgeprice = NormalizeDouble(hedgeprice, Digits);
            StopLoss = NormalizeDouble(StopLoss, Digits);
            Print(" HedgePrice : ", hedgeprice, " StopLoss : ", StopLoss);
            double Lot = 0;
            if(Orders[i].zone == "AGGRESSIVE")
               Lot = Lot_Size;
            else
               Lot = ConservativeLot_Size;

            int ticket = Place_Order_Hedge(Magic_Number,OP_BUYSTOP,hedgeprice,Lot,StopLoss, 0);
            if(ticket != -1)
              {
               Print("Hedge Order Ticket  : ", ticket);
               Orders[i].hedge_ticket = ticket;
               Orders[i].hedge_price = hedgeprice;
               Orders[i].hedge_sl = StopLoss;
               Orders[i].hedge_lot = Lot;
               Orders[i].hedge_count = Orders[i].hedge_count + 1;
               create_hedge_entry_line(hedgeprice,OP_SELL);
               create_hedge_sl_line(StopLoss,OP_SELL);
              }
           }
        }
     }
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1 && Orders[i].hedge_ticket != -1)
        {
         if(OrderSelect(Orders[i].hedge_ticket, SELECT_BY_TICKET))
           {
            if(OrderType() == OP_SELL)
              {
               if(OrderCloseTime() > 0)
                 {
                  if(Orders[i].hedge_count < Total_Hits)
                    {
                     int ticket = Place_Order_Hedge(Magic_Number,OP_SELLSTOP,Orders[i].hedge_price,Orders[i].hedge_lot,Orders[i].hedge_sl, 0);
                     if(ticket != -1)
                       {
                        Orders[i].hedge_ticket = ticket;
                        Orders[i].hedge_count = Orders[i].hedge_count + 1;
                        create_hedge_entry_line(Orders[i].hedge_price, Orders[i].Order_Type);
                        create_hedge_sl_line(Orders[i].hedge_sl, Orders[i].Order_Type);
                       }
                    }
                  else
                    {
                     Print("MAX HITS REACHED : ", Orders[i].hedge_count);
                     if(Close_Max_Hits)
                       {

                        if(OrderClose(Orders[i].Ticket,OrderLots(),Bid,3,clrRed))
                          {
                           Print("ORDERS CLOSED  !!");
                           Orders[i].OpenPrice = -1;
                           Orders[i].hedge_ticket = -1;
                           ObjectDelete(hedge_entry_line);
                           ObjectDelete(hedge_sl_line);
                           ObjectDelete(buy_sl_line);
                          }
                       }
                    }
                 }
              }
            if(OrderType() == OP_BUY)
              {
               if(OrderCloseTime() > 0)
                 {
                  if(Orders[i].hedge_count < Total_Hits)
                    {
                     int ticket = Place_Order_Hedge(Magic_Number,OP_BUYSTOP,Orders[i].hedge_price,Orders[i].hedge_lot,Orders[i].hedge_sl, 0);
                     if(ticket != -1)
                       {
                        Orders[i].hedge_ticket = ticket;
                        Orders[i].hedge_count = Orders[i].hedge_count + 1;
                        create_hedge_entry_line(Orders[i].hedge_price, Orders[i].Order_Type);
                        create_hedge_sl_line(Orders[i].hedge_sl, Orders[i].Order_Type);
                       }
                    }
                  else
                    {
                     Print("MAX HITS REACHED : ", Orders[i].hedge_count);
                     if(Close_Max_Hits)
                       {
                        if(OrderClose(Orders[i].Ticket,OrderLots(),Ask,3,clrRed))
                          {
                           Print("ORDERS CLOSED  !!");
                           Orders[i].OpenPrice = -1;
                           Orders[i].hedge_ticket = -1;
                           ObjectDelete(hedge_entry_line_sel);
                           ObjectDelete(hedge_sl_line_sell);
                           ObjectDelete(sell_sl_line);
                          }
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void close_on_drawdown()
  {
   double total_profit = 0;
   datetime base_order_time = 0;
   int base_order_ticket = 0;
   double base_order_balance = 0;
   for(int i=0; i<MaxOrders; i++)
     {
      if(Orders[i].OpenPrice != -1)
        {
         if(OrderSelect(Orders[i].Ticket, SELECT_BY_TICKET))
           {
            total_profit = total_profit + OrderProfit();
            base_order_time = Orders[i].OpenTime;
            base_order_ticket = Orders[i].Ticket;
            base_order_balance = Orders[i].initial_balance;
           }
        }
     }


   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderOpenTime() >= base_order_time && OrderCloseTime() > 0)
           {
            total_profit = total_profit + OrderProfit();
           }
        }
     }

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderTicket() != base_order_ticket && OrderOpenTime() > base_order_time)
           {
            total_profit = total_profit + OrderProfit();
           }
        }
     }

   double drawdown_balance = -1 * (base_order_balance/100) * Hedge_Loss;
   if(drawdown_balance != 0)
     {
      if(total_profit <= drawdown_balance)
        {
         Print("Max Hedge Drawdown balance Reached : ", total_profit, " Desired Loss : ", drawdown_balance);
         closeAllTrades();
         ObjectDelete(hedge_entry_line);
         ObjectDelete(hedge_sl_line);
         ObjectDelete(buy_sl_line);
         for(int i=0; i<MaxOrders; i++)
           {
            if(Orders[i].OpenPrice != -1)
              {
               Orders[i].OpenPrice = -1;
               Orders[i].hedge_ticket = -1;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void closeAllTrades()
  {
   for(int i = OrdersTotal(); i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_Number)
           {
            if((OrderType() == OP_BUY || OrderType() == OP_SELL))
              {
               //Print("Just Before Close");
               if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, clrGreen))
                 {
                  Print("Problem in closing order", GetLastError());
                 }
               else
                  Print("Order Closed");
              }
            if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || (OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT))
              {
               if(!OrderDelete(OrderTicket(), clrBrown))
                 {
                  Print("Problem in closing Pending order ", GetLastError());
                 }
               Print("Pending Orders Closed");
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool create_hedge_entry_line(double price,ENUM_ORDER_TYPE type)
  {
   if(type == OP_BUY)
     {
      ObjectDelete(hedge_entry_line);
      if(!ObjectCreate(0,hedge_entry_line,OBJ_HLINE,0,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        }
      else
        {
         ObjectSetInteger(0,hedge_entry_line,OBJPROP_COLOR,hedge_entry_clr);
         ObjectSetInteger(0,hedge_entry_line,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,hedge_entry_line,OBJPROP_WIDTH,Line_Width);
         ObjectSetInteger(0,hedge_entry_line,OBJPROP_BACK,true);
         ObjectSetInteger(0,hedge_entry_line,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,hedge_entry_line,OBJPROP_SELECTED,false);
         return true;
        }
     }
   if(type == OP_SELL)
     {
      ObjectDelete(hedge_entry_line_sel);
      if(!ObjectCreate(0,hedge_entry_line_sel,OBJ_HLINE,0,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        }
      else
        {
         ObjectSetInteger(0,hedge_entry_line_sel,OBJPROP_COLOR,hedge_entry_clr);
         ObjectSetInteger(0,hedge_entry_line_sel,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,hedge_entry_line_sel,OBJPROP_WIDTH,Line_Width);
         ObjectSetInteger(0,hedge_entry_line_sel,OBJPROP_BACK,true);
         ObjectSetInteger(0,hedge_entry_line_sel,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,hedge_entry_line_sel,OBJPROP_SELECTED,false);
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
bool create_hedge_sl_line(double price,ENUM_ORDER_TYPE type)
  {
   if(type == OP_BUY)
     {
      ObjectDelete(hedge_sl_line);
      if(!ObjectCreate(0,hedge_sl_line,OBJ_HLINE,0,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        }
      else
        {
         ObjectSetInteger(0,hedge_sl_line,OBJPROP_COLOR,hedge_sl_clr);
         ObjectSetInteger(0,hedge_sl_line,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,hedge_sl_line,OBJPROP_WIDTH,Line_Width);
         ObjectSetInteger(0,hedge_sl_line,OBJPROP_BACK,true);
         ObjectSetInteger(0,hedge_sl_line,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,hedge_sl_line,OBJPROP_SELECTED,false);
         return true;
        }
     }
   if(type == OP_SELL)
     {
      ObjectDelete(hedge_sl_line_sell);
      if(!ObjectCreate(0,hedge_sl_line_sell,OBJ_HLINE,0,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        }
      else
        {
         ObjectSetInteger(0,hedge_sl_line_sell,OBJPROP_COLOR,hedge_sl_clr);
         ObjectSetInteger(0,hedge_sl_line_sell,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,hedge_sl_line_sell,OBJPROP_WIDTH,Line_Width);
         ObjectSetInteger(0,hedge_sl_line_sell,OBJPROP_BACK,true);
         ObjectSetInteger(0,hedge_sl_line_sell,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,hedge_sl_line_sell,OBJPROP_SELECTED,false);
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool create_order_sl_line(double price, ENUM_ORDER_TYPE type)
  {
   if(type == OP_BUY)
     {
      ObjectDelete(buy_sl_line);
      if(!ObjectCreate(0,buy_sl_line,OBJ_HLINE,0,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        }
      else
        {
         ObjectSetInteger(0,buy_sl_line,OBJPROP_COLOR,buy_sl_clr);
         ObjectSetInteger(0,buy_sl_line,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,buy_sl_line,OBJPROP_WIDTH,Line_Width);
         ObjectSetInteger(0,buy_sl_line,OBJPROP_BACK,true);
         ObjectSetInteger(0,buy_sl_line,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,buy_sl_line,OBJPROP_SELECTED,false);
         return true;
        }
     }
   if(type == OP_SELL)
     {
      ObjectDelete(sell_sl_line);
      if(!ObjectCreate(0,sell_sl_line,OBJ_HLINE,0,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        }
      else
        {
         ObjectSetInteger(0,sell_sl_line,OBJPROP_COLOR,buy_sl_clr);
         ObjectSetInteger(0,sell_sl_line,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,sell_sl_line,OBJPROP_WIDTH,Line_Width);
         ObjectSetInteger(0,sell_sl_line,OBJPROP_BACK,true);
         ObjectSetInteger(0,sell_sl_line,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,sell_sl_line,OBJPROP_SELECTED,false);
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculate_new_scaling_lot()
  {
   int Mode_Factor = (int)(AccountBalance()/ScalingBalance);
   if(Mode_Factor <= 1)
     {
      newScalingBuyLot = ScalingLot;
      newScalingBuyTp1Lot = NormalizeDouble(newScalingBuyLot/3,2);
      newScalingBuyTp2Lot = NormalizeDouble(newScalingBuyLot/3,2);

      newScalingSellLot = ScalingLot;
      newScalingSellTp1Lot = NormalizeDouble(newScalingSellLot/3,2);
      newScalingSellTp2Lot = NormalizeDouble(newScalingSellLot/3,2);
     }
   else
     {
      newScalingBuyLot = ScalingLot * Mode_Factor;
      newScalingBuyTp1Lot = NormalizeDouble(newScalingBuyLot/3,2);
      newScalingBuyTp2Lot = NormalizeDouble(newScalingBuyLot/3,2);

      newScalingSellLot = ScalingLot * Mode_Factor;
      newScalingSellTp1Lot = NormalizeDouble(newScalingSellLot/3,2);
      newScalingSellTp2Lot = NormalizeDouble(newScalingSellLot/3,2);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_super_Trend_Blocks(bool isAggressive)
  {
   datetime pastCandleTime = iTime(Symbol(), super_MA_TimeFrame, 1);
   datetime currentCandleTime = iTime(Symbol(), super_MA_TimeFrame, 0);
   Print("Rectangle Draw Candl - 1 : ",pastCandleTime, " Rectangle Draw Candl - 1 : ", currentCandleTime);
   double ChartMaxPrice = ChartGetDouble(0,CHART_PRICE_MAX,0);
   double ChartMinPrice = ChartGetDouble(0,CHART_PRICE_MIN,0);

   if(isAggressive)
     {
      if(ObjectFind(aggressive_trend+(string)currentCandleTime) < 0)
         if(!ObjectCreate(0,aggressive_trend+(string)currentCandleTime,OBJ_RECTANGLE,0,pastCandleTime,ChartMaxPrice,currentCandleTime,ChartMinPrice))
           {
            Print(__FUNCTION__,
                  ": failed to create a rectangle! Error code = ",GetLastError());
           }
         else
           {
            //--- set rectangle color
            ObjectSetInteger(0,aggressive_trend+(string)currentCandleTime,OBJPROP_COLOR,Aggressive_color);
            ObjectSetInteger(0,aggressive_trend+(string)currentCandleTime,OBJPROP_BACK,true);
           }
     }
   else
     {
      if(ObjectFind(conservative_trend+(string)currentCandleTime) < 0)
         if(!ObjectCreate(0,conservative_trend+(string)currentCandleTime,OBJ_RECTANGLE,0,pastCandleTime,ChartMaxPrice,currentCandleTime,ChartMinPrice))
           {
            Print(__FUNCTION__,
                  ": failed to create a rectangle! Error code = ",GetLastError());
           }
         else
           {
            //--- set rectangle color
            ObjectSetInteger(0,conservative_trend+(string)currentCandleTime,OBJPROP_COLOR,Conservative_color);
            ObjectSetInteger(0,conservative_trend+(string)currentCandleTime,OBJPROP_BACK,true);
           }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Update_Super_Trend_Blocks_price()
  {
   double ChartMaxPrice = ChartGetDouble(0,CHART_PRICE_MAX,0);
   double ChartMinPrice = ChartGetDouble(0,CHART_PRICE_MIN,0);
   if(ChartMaxPrice != chart_max_price || ChartMinPrice != chart_min_price)
     {
      chart_max_price = ChartMaxPrice;
      chart_min_price = ChartMinPrice;
      for(int i=0; i<ObjectsTotal(); i++)
        {
         string name = ObjectName(i);
         if(StringFind(name,aggressive_trend,0) >= 0 || StringFind(name,conservative_trend,0) >= 0)
           {
            double price1 = ObjectGetDouble(0,name,OBJPROP_PRICE1,0);
            double price2 = ObjectGetDouble(0,name,OBJPROP_PRICE2,0);

            if(ChartMaxPrice != price1)
               ObjectSetDouble(0,name,OBJPROP_PRICE1,ChartMaxPrice);
            if(ChartMinPrice != price2)
               ObjectSetDouble(0,name,OBJPROP_PRICE2,ChartMinPrice);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EMA_Angle()
  {
   double ema1, ema2, angle;
   datetime time1, time2;
   ema1 = iMA(Symbol(), super_MA_TimeFrame, super_ma_period, 0, super_ma_mode, super_ma_price, 1);
   ema2 = iMA(Symbol(), super_MA_TimeFrame, super_ma_period, 0, super_ma_mode, super_ma_price, angle_candle_shift);
   time1 = iTime(Symbol(), super_MA_TimeFrame, 1);
   time2 = iTime(Symbol(), super_MA_TimeFrame, angle_candle_shift);

   int X2, Y2, X1, Y1;
   if(!ChartTimePriceToXY(0, 0, time2, ema2, X2, Y2))
      Print("Error : ", GetLastError());
   if(!ChartTimePriceToXY(0, 0, time1, ema1, X1, Y1))
      Print("Error : ", GetLastError());
   angle = MathArctan((double)(Y2-Y1)/(double)(X1-X2))*180/M_PI;
   return angle;
  }
//+------------------------------------------------------------------+
