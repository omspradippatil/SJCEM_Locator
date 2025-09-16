# SJCEM Navigator

A campus navigation and management app for St. John College of Engineering and Management.

## Features

- Campus map navigation with floor plans
- Faculty directory with real-time availability
- Class schedules and timetables
- Student and faculty profiles
- Authentication system with role-based access

## Getting Started

### Prerequisites

- Flutter SDK: 3.0.0 or higher
- Supabase account with a project set up

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/SJCEM_Locator.git
    cd SJCEM_Locator
    ```

2. Install dependencies:
    ```bash
    flutter pub get
    ```

3. Run the app with Supabase credentials:
    ```bash
    flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_KEY=your_supabase_anon_key
    ```

## Database Setup

The app requires the following tables in your Supabase project:
- users
- timetable
- locations
- faculty_availability

Refer to the SQL setup scripts in the project documentation.

## Images Storage

Upload images to the following Supabase storage buckets:
- avatars: For user profile pictures
- campus: For campus maps and location images

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
