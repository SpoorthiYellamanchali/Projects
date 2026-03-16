#include <avr/io.h>
#include <util/delay.h>

#define F_CPU 16000000UL  // CPU clock speed

// **BCD Pins (Arduino → 7447 Decoder)**
#define BCD_A PD2
#define BCD_B PD3
#define BCD_C PD4
#define BCD_D PD5

// **7-Segment Display Selection Pins**
#define DISP1 PD6
#define DISP2 PD7
#define DISP3 PB0
#define DISP4 PB1
#define DISP5 PB2
#define DISP6 PB3

// **Push Buttons**
#define HOUR_BUTTON PB4
#define MIN_BUTTON PC0
#define SEC_BUTTON PC1

// **Time Variables**
volatile uint8_t hours = 0, minutes = 0, seconds = 0;

// **BCD Encoder Function**
void setBCD(uint8_t num) {
    PORTD = (PORTD & 0xC3) | ((num & 0x0F) << 2);
}

// **Multiplexing Function for Display Selection**
void selectDisplay(uint8_t disp) {
    PORTD &= ~((1 << DISP1) | (1 << DISP2));
    PORTB &= ~((1 << DISP3) | (1 << DISP4) | (1 << DISP5) | (1 << DISP6));

    switch (disp) {
        case 0: PORTD |= (1 << DISP1); break;  // Hour Tens
        case 1: PORTD |= (1 << DISP2); break;  // Hour Units
        case 2: PORTB |= (1 << DISP3); break;  // Minute Tens
        case 3: PORTB |= (1 << DISP4); break;  // Minute Units
        case 4: PORTB |= (1 << DISP5); break;  // Second Tens
        case 5: PORTB |= (1 << DISP6); break;  // Second Units
    }
}

// **Update Display with Current Time (Improved Multiplexing)**
void displayTime() {
    uint8_t digits[6] = {
        hours / 10, hours % 10,
        minutes / 10, minutes % 10,
        seconds / 10, seconds % 10
    };

    static uint8_t currentDisplay = 0;
    
    setBCD(digits[currentDisplay]);  // Send BCD to 7447
    selectDisplay(currentDisplay);   // Activate one display
    currentDisplay = (currentDisplay + 1) % 6;  // Cycle through displays
}

// **Software Timer to Keep Accurate Seconds (Non-blocking)**
void incrementTime() {
    static uint16_t counter = 0;
    
    counter++;
    if (counter >= 200) {  // ~200 x 5ms = 1 second
        counter = 0;

        seconds++;
        if (seconds == 60) {  
            seconds = 0;  
            minutes++;
            
            if (minutes == 60) {  
                minutes = 0;
                hours++;
                
                if (hours == 24) {  
                    hours = 0;  
                }
            }
        }
    }
}

// **Button Handling**
void checkButtons() {
    if (!(PINB & (1 << HOUR_BUTTON))) {
        _delay_ms(50);
        if (!(PINB & (1 << HOUR_BUTTON))) {
            hours = (hours + 1) % 24;
        }
    }
    if (!(PINC & (1 << MIN_BUTTON))) {
        _delay_ms(50);
        if (!(PINC & (1 << MIN_BUTTON))) {
            minutes = (minutes + 1) % 60;
        }
    }
    if (!(PINC & (1 << SEC_BUTTON))) {
        _delay_ms(50);
        if (!(PINC & (1 << SEC_BUTTON))) {
            seconds = (seconds + 1) % 60;
        }
    }
}

// **Main Function**
int main() {
    // **Set BCD and Display Pins as Outputs**
    DDRD |= (1 << BCD_A) | (1 << BCD_B) | (1 << BCD_C) | (1 << BCD_D);
    DDRD |= (1 << DISP1) | (1 << DISP2);
    DDRB |= (1 << DISP3) | (1 << DISP4) | (1 << DISP5) | (1 << DISP6);

    // **Set Push Buttons as Inputs with Pull-ups**
    DDRB &= ~(1 << HOUR_BUTTON);
    DDRC &= ~((1 << MIN_BUTTON) | (1 << SEC_BUTTON));
    PORTB |= (1 << HOUR_BUTTON);
    PORTC |= (1 << MIN_BUTTON) | (1 << SEC_BUTTON);

    // **Clock starts at 00:00:00**
    hours = 0;
    minutes = 0;
    seconds = 0;

    while (1) {
        checkButtons();   // Check button presses
        incrementTime();  // Update time if needed
        displayTime();    // Refresh the display continuously
        _delay_ms(5);     // Short delay for proper multiplexing
    }
}
