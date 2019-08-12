#include <LiquidCrystal.h>
#include <SoftwareSerial.h>

#define TRUE 1
#define FALSE 0

LiquidCrystal lcd( 8,9,10,11,12,13 );
SoftwareSerial bluetooth( 6, 7 ); // TX, RX
const int ledPin = 2;  int relay = 4;

char  BRchar;   
String BRString = "";

int isOnOff = 1;  // 최초 On
unsigned long OnTime =  1000ul * 4ul; // msec : 입력 받을값  (ul 표시는 String변환시에 필요)
unsigned long OffTime = 3000ul; // msec : 입력 받을값

unsigned long PrevTime = 0;   // OnOff 간격체크 누적값
unsigned long DPrevTime = 0;  // 화면표시 간격체크 누적값
unsigned long IntevalTime = OnTime;
int DMCount= 0;
bool isTimerOn = FALSE;
 
void setup() {
  pinMode(ledPin, OUTPUT);  
  pinMode(relay, OUTPUT);  
  lcd.begin(16, 2);
  Serial.begin(9600);  
  bluetooth.begin(9600);  
  Display_Text( 0, "Welcome Delphi.." );

  digitalWrite(ledPin, HIGH);  // 시작시 On
  digitalWrite(relay, HIGH); 
}

void loop() { 
  if ( millis() - PrevTime > IntevalTime  && isTimerOn == TRUE  ){    // IntevalTime 간격마다 반복 실행
     PrevTime =  millis();  // 다음반복 시간 지정 ~ 계속 증가됨.

     switch ( isOnOff ) {
       case 1 : isOnOff = 0;  IntevalTime = OffTime;  digitalWrite(ledPin, LOW);  digitalWrite(relay, LOW);  break;
       case 0 : isOnOff = 1;  IntevalTime = OnTime;   digitalWrite(ledPin, HIGH); digitalWrite(relay, HIGH);  break;
     }
     DMCount = 0; // Time_Display 초기화
  }
//  Serial.println(  String( IntevalTime ) );
  Time_Display( 1, IntevalTime );
  
  if(bluetooth.available()) {  
     BRchar = bluetooth.read();   // loop 마다 한글자(1 Byte)씩 받아옴
       
     if ( BRchar == 0x15 ) {
        switch( BRString.toInt() ) {
          case 0 : digitalWrite(ledPin, LOW);  digitalWrite(relay, LOW);   break;
          case 1 : digitalWrite(ledPin, HIGH); digitalWrite(relay, HIGH);  break; 
        }
        BRString = "";
        isTimerOn = FALSE;  // 강제 On/Off 시는 Interval 타이머 작동중지 
     }

     else if ( BRchar == 0x13 || BRchar == 0x14 ){          
        switch( BRchar ) {
          case  0x13 :  OnTime = BRString.toInt() * 1000; // sec 단위로 입력받음
                        IntevalTime = OnTime;            
                        BRString = "";  break;
                         
          case  0x14 :  OffTime =  BRString.toInt() * 1000; // sec 단위로 입력받음
                        isOnOff = 0;         PrevTime = 0;         DPrevTime = 0;      DMCount = 0;  // 초기화하고 새로시작
                        Display_Text( 0, "On:"+ String(OnTime/1000) + " Off:"+  String(OffTime/1000) );                          
                        digitalWrite(ledPin, HIGH);  
                        digitalWrite(relay, HIGH);            
                        BRString = "";    break;
        }
        isTimerOn = TRUE; // 새로운 Interval 명령입력시 타이머 다시 작동
     }
     else{
        BRString.concat( BRchar );   // 1 문자씩 추가해서 문자열 생성
        Serial.println( BRString );
     }     
  } 
  delay(1);       
}

// 지정시간 간격대로 화면표시 
void Time_Display( int DispInterval, unsigned long startTime ){  // DispInterval : 화면표시 간격(초), startTimet : 시작시간 
  DispInterval = DispInterval * 1000;  // sec Input  
  startTime = startTime / 1000ul; 
  
  if ( millis() - DPrevTime > DispInterval  && isTimerOn == TRUE ){    
      DPrevTime =  millis();  // 계속 누적됨.
      Display_Text( 1, "D-" + String( (startTime - DMCount) ) + " sec" ); 
      if ( startTime <= DMCount ) DMCount = 0;
      else                        DMCount = DMCount + 1;   
  } 
}

void Display_Text( int LineNo,  String dText ) {
     //lcd.clear();  
     switch( LineNo ){
       case 0 : lcd.setCursor(0, 0); break; 
       case 1 : lcd.setCursor(0, 1); break;       
     }
     lcd.print( dText );  
          
     int space = 16 - dText.length();     
     for( int i = space; i<= 16;  i++ )  lcd.print(" ");  // 여백 채움.
}

















