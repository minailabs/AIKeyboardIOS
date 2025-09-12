# AI Keyboard - Custom iOS Keyboard

A custom iOS keyboard extension with dark theme, QWERTY layout, and predictive text suggestions, designed to match the modern iOS keyboard aesthetic.

## Features

✨ **Dark Theme**: Beautiful dark interface with rounded gray keys  
⌨️ **QWERTY Layout**: Standard keyboard layout with proper key spacing  
🔮 **Predictive Text**: Suggestion bar with common words ("I", "The", "I'm")  
🔧 **Special Keys**: Shift, delete, space, return, numbers, and emoji access  
🌐 **Globe Icon**: Easy keyboard switching  
🎤 **Microphone Icon**: Voice input support  
✨ **Visual Feedback**: Keys animate when pressed for better UX  

## Screenshot

The keyboard matches the design shown in your screenshot with:
- Dark background (RGB: 28, 28, 30)
- Gray keys (RGB: 64, 64, 69) with 8px corner radius
- White text and icons
- Proper spacing and sizing for all screen sizes
- Suggestion bar at the top
- Globe and microphone icons at the bottom

## Installation

1. **Build the Project**:
   ```bash
   xcodebuild -project AIKeyboard.xcodeproj -scheme AIKeyboard -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' build
   ```

2. **Install on Device/Simulator**:
   - Run the project in Xcode
   - The main app provides setup instructions

3. **Enable the Keyboard**:
   - Go to Settings → General → Keyboard → Keyboards
   - Tap "Add New Keyboard..."
   - Select "AIKeyboard" from the list
   - Switch to the keyboard by tapping the globe icon

## Project Structure

```
AIKeyboard/
├── AIKeyboard/                 # Main app
│   ├── AIKeyboardApp.swift    # App entry point
│   ├── ContentView.swift      # Setup instructions UI
│   └── Assets.xcassets/       # App assets
└── AIKeyboardExt/             # Keyboard extension
    ├── KeyboardViewController.swift  # Main keyboard implementation
    └── Info.plist            # Extension configuration
```

## Technical Implementation

### KeyboardViewController.swift
- **Custom Layout**: Programmatically created QWERTY keyboard using UIStackView
- **Dark Theme**: Custom colors matching iOS dark mode
- **Touch Feedback**: Animated button presses with scale and color changes
- **Text Input**: Full integration with iOS text input system
- **Special Keys**: Proper handling of shift, delete, space, and return keys

### Key Features
- **Suggestion Bar**: Displays predictive text options
- **Adaptive Layout**: Responsive design for different screen sizes
- **Visual Feedback**: Buttons animate on touch for better UX
- **Icon Integration**: SF Symbols for shift, delete, globe, and microphone icons

## Customization

You can easily customize the keyboard by modifying:
- **Colors**: Update the RGB values in `createKeyButton()`
- **Layout**: Modify the `keyboardRows` array
- **Suggestions**: Change the `suggestions` array
- **Key Sizes**: Adjust constraint constants in `setupBottomRow()`

## Requirements

- iOS 18.5+
- Xcode 16+
- Swift 5.0+

## License

This project is created for educational purposes. Feel free to use and modify as needed.
