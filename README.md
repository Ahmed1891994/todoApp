# Enhanced Todo App - Flutter

A feature-rich, cross-platform todo application built with Flutter that works seamlessly on both web and mobile platforms. Built with clean architecture principles and modern Flutter practices.

## 🚀 Features

### Core Functionality
- ✅ Add, edit, delete, and mark todos as complete
- 📝 Task descriptions and titles
- 🏷️ Categorize tasks (Personal, Work, Shopping, Health, Other)
- ⚡ Priority levels (Low, Medium, High) with color coding
- 📅 Due dates with visual indicators for overdue tasks

### Advanced Features (Phase 2)
- 🔄 **Recurring Tasks**: Daily, weekly, monthly recurrence with auto-creation
- 🔍 **Advanced Filtering**: Multi-criteria filtering (category + priority + due date + search)
- 📋 **Task Templates**: Save common tasks as templates for quick reuse
- 🎯 **Drag & Drop**: Reorder tasks with intuitive drag and drop
- ✨ **Smooth Animations**: Beautiful animations for all interactions
- 🌙 **Enhanced Themes**: Improved dark/light theme switching with persistence

### User Experience
- ✨ Clean, modern UI with Material Design 3
- 🎯 Intuitive task management
- 🔄 Real-time updates
- 📱 Mobile-friendly gestures
- 🖥️ Desktop-optimized interactions

## 🏗️ Architecture

The app follows Clean Architecture with clear separation of concerns:

### Presentation Layer
- **Widgets**: UI components built with Flutter
- **State Management**: Provider pattern for efficient state handling
- **Themes**: Customizable light/dark themes

### Domain Layer
- **Entities**: Business logic and data models
- **Repository Interfaces**: Abstract data operations

### Data Layer
- **Models**: Data transfer objects
- **Repositories**: Concrete implementations of data operations
- **Data Sources**: Local storage handling

## 🛠️ Technology Stack

- **Flutter**: Cross-platform framework
- **Dart**: Programming language
- **Provider**: State management
- **Shared Preferences**: Local data persistence
- **Intl**: Internationalization and date formatting

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd enhanced_todo_app```
   
2. **Install dependencies**

	```bash flutter pub get```
	
3. **Run the application**
	```bash 
	# For web
	lutter run -d chrome

	# For mobile
	flutter run```
	
## 📦 Usage
### Adding a Task
Enter task title in the input field

(Optional) Add description, due date, category, priority, recurrence

Click "Add Todo" button


### Managing Tasks
Complete: Check the checkbox

Edit: Click the edit icon

Delete: Click the delete icon or swipe to delete

Reorder: Drag and drop to reorder tasks

Filter: Use the filter icon in app bar for advanced filtering

### Recurring Tasks
Set recurrence to daily, weekly, or monthly

Tasks automatically recreate when completed

Set end dates for recurring tasks

### Templates
Save frequently used tasks as templates

Access templates from the templates icon in app bar

Quick-add templates with single click

## Platforms Supported
Web: Chrome, Firefox, Safari, Edge

Android: Phones and tablets

iOS: iPhones and iPads

Desktop: Windows, macOS, Linux (with Flutter desktop)

## Customization
Adding New Categories
Edit the categories list in lib/presentation/widgets/todo_form.dart

Modifying Themes
Update color schemes and styles in lib/core/themes/app_themes.dart

Changing Storage
Implement different data sources by extending the repository interface

🧪 Testing
Run tests with:

bash
flutter test
📊 Performance
Optimized rebuilds with Provider

Efficient list rendering with ListView.builder

Minimal state updates

Fast local storage operations

🔮 Future Enhancements
Cloud synchronization

Task reminders and notifications

Task sharing and collaboration

Advanced filtering and search

Multi-language support

Accessibility features