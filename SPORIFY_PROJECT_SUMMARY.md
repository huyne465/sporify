# SPORIFY - Music Streaming App Project Summary

## 🎵 Dự án Tổng quan
Sporify là ứng dụng nghe nhạc streaming được phát triển bằng Flutter, tích hợp với Firebase và Spotify API, hỗ trợ cả chức năng nghe nhạc và quản trị upload nhạc.

## 🚀 Key Features

### 1. Xác thực và Quản lý người dùng
- **Đăng ký/Đăng nhập** với email và mật khẩu
- **Đăng nhập mạng xã hội**: Google Sign-In và Facebook Login
- **Quên mật khẩu** với Firebase Auth
- **Thay đổi mật khẩu** và quản lý tài khoản
- **Dark mode/Light mode** với theme cubit
- **Liên kết tài khoản** (Link Google/Facebook account)

### 2. Phát nhạc và Audio
- **Trình phát nhạc toàn cục** (Global Music Player)
- **Mini player** hiển thị ở bottom
- **Just Audio** integration cho audio streaming
- **Audioplayers** hỗ trợ audio formats
- **Playlist mode** và **Random mode**
- **Skip previous/next**, Play/Pause controls
- **Seek to position** trong bài hát
- **Progress bar** với thời gian thực
- **Background music playback**

### 3. Quản lý nhạc cá nhân
- **Thêm/Xóa bài hát yêu thích** (Favorite songs)
- **Tạo playlist cá nhân**
- **Thêm/Xóa nhạc khỏi playlist**
- **Chia sẻ playlist** qua social media
- **Upload ảnh cover** cho playlist
- **Tìm kiếm bài hát** theo tên và nghệ sĩ

### 4. Spotify Integration
- **Spotify Web API** tích hợp
- **Browse Spotify popular tracks**
- **Artist details** và top tracks
- **Album browsing**
- **Preview 30s** cho Spotify tracks
- **Open in Spotify** functionality
- **Spotify OAuth** authentication

### 5. Admin Panel - Upload nhạc
- **Upload file nhạc** (MP3, WAV, AAC, M4A, OGG, FLAC)
- **Upload ảnh cover** (JPG, PNG, GIF, WebP)
- **Metadata management** (title, artist, album, genre, duration)
- **File validation** (kích thước, định dạng)
- **Progress tracking** khi upload
- **Firebase Storage** integration
- **Storage statistics** (tổng số bài, dung lượng)
- **Song management** (xem, xóa, cập nhật)

### 6. Hiển thị lyrics
- **Lyrics display** với time sync
- **Toggle lyrics view** trong song player
- **Lyrics cubit** quản lý state

### 7. Chia sẻ và Social
- **Share songs** qua multiple platforms
- **Social Sharing Plus** integration
- **Share playlists** with generated links
- **Support links** to Spotify support

## 🛠️ Công nghệ và Frameworks

### Frontend Framework
- **Flutter** 3.8.0+
- **Dart** programming language
- **Material Design** 3 components

### State Management
- **Flutter BLoC** (Cubit pattern)
- **Hydrated BLoC** (persistent state)
- **Provider pattern** for dependency injection

### Backend và Database
- **Firebase** ecosystem:
  - **Firebase Auth** (authentication)
  - **Cloud Firestore** (database)
  - **Firebase Storage** (file storage)
  - **Firebase Core** 2.32.0

### Audio và Media
- **Just Audio** (primary audio player)
- **Audioplayers** 5.0.0 (secondary audio support)
- **Cached Network Image** 3.4.1 (image caching)

### File Handling
- **File Picker** 8.0.0+1 (file selection)
- **Image Picker** 1.0.7 (image selection)
- **Path** 1.8.3 (file path utilities)

### Social Authentication
- **Google Sign-In** 6.0.2
- **Facebook Auth** 6.0.4
- **OAuth2** 2.0.1

### Sharing và Social Media
- **Share Plus** 7.2.2
- **Social Sharing Plus** 1.2.3
- **URL Launcher** (external links)

### UI và Styling
- **Flutter SVG** 2.0.9 (vector graphics)
- **Custom themes** (dark/light mode)
- **Satoshi font family** (custom fonts)

### HTTP và Networking
- **HTTP** 1.4.0 (API calls)
- **Dartz** (functional programming)

### Local Storage
- **Path Provider** (local file system)
- **GetIt** (service locator pattern)

## 🔑 API Keys và External Services

### Firebase Configuration
- **Project ID**: sporify01
- **Firebase Web API Key**: AIzaSyAHcv11AlWibt19d_dYPq-hoZfya7RaDfw
- **App ID**: 1:91817906532:web:7f72683324311ccc4f6a71
- **Storage Bucket**: sporify01.firebasestorage.app

### Spotify Integration
- **Spotify Web API** endpoint: https://api.spotify.com/v1/
- **Client credentials** authentication
- **Player API** for playback control
- **Search API** for tracks và artists

### Social Media APIs
- **Google Sign-In** với SHA certificate
- **Facebook App** với package signature
- **Social sharing** platforms (Twitter, Instagram, LinkedIn)

## 🌐 API Endpoints và External Services

### 1. Firebase APIs
#### Firebase Authentication API
- **Endpoint**: Firebase Auth SDK
- **Methods Used**:
  - `createUserWithEmailAndPassword()`
  - `signInWithEmailAndPassword()`
  - `signInWithCredential()` (Google/Facebook)
  - `sendPasswordResetEmail()`
  - `updatePassword()`
  - `signOut()`

#### Cloud Firestore API
- **Endpoint**: Firestore SDK
- **Collections**:
  - `users/{userId}` - User profile data
  - `users/{userId}/favorites` - User favorite songs
  - `users/{userId}/playlists` - User playlists
  - `songs` - All songs collection
  - `artists` - Artists collection
- **Operations**: CRUD operations, real-time listeners, queries

#### Firebase Storage API
- **Endpoint**: Firebase Storage SDK
- **Bucket**: `sporify01.firebasestorage.app`
- **Operations**:
  - Upload audio files (MP3, WAV, AAC, M4A, OGG, FLAC)
  - Upload image files (JPG, PNG, GIF, WebP)
  - Delete files
  - Get download URLs
  - File validation

### 2. Spotify Web API
#### Base URL: `https://api.spotify.com/v1`
#### Authentication Endpoint
- **POST** `https://accounts.spotify.com/api/token`
- **Grant Type**: client_credentials
- **Headers**: Basic Authentication with Client ID/Secret

#### Search API
- **GET** `/search?q={query}&type=artist,track,album&limit={limit}`
- **Purpose**: Search for artists, tracks, albums

#### Artists API
- **GET** `/artists/{artistId}/top-tracks?market=US`
- **Purpose**: Get artist's top tracks

#### Player API (Web Playback)
- **PUT** `/me/player/play`
- **PUT** `/me/player/pause`
- **Body**: JSON with track URIs or context URIs

### 3. Lyrics API
#### LRCLib API
- **Base URL**: `https://lrclib.net/api`
- **Endpoint**: **GET** `/get?artist_name={artist}&track_name={track}`
- **Headers**: `User-Agent: Sporify/1.0.0`
- **Response**: Lyrics with synced timestamps
- **Purpose**: Fetch song lyrics with time synchronization

### 4. Social Authentication APIs
#### Google Sign-In API
- **SDK**: Google Sign-In Flutter Plugin
- **Scopes**: Basic profile, email
- **Platform**: Android/iOS/Web

#### Facebook Login API
- **SDK**: Facebook Login Flutter Plugin
- **Permissions**: email, public_profile
- **Platform**: Android/iOS

### 5. File and Media APIs
#### File Picker API
- **Platform**: Native file picker
- **Supported Types**: Audio files, images
- **Purpose**: Select files for upload

#### Image Picker API
- **Platform**: Native camera/gallery
- **Purpose**: Pick images from camera or gallery

#### URL Launcher API
- **Purpose**: Open external URLs
- **Modes**: 
  - External browser
  - In-app web view
  - Platform default

### 6. Social Sharing APIs
#### Share Plus API
- **Purpose**: Share content across platforms
- **Supported**: Text, files, URLs

#### Social Sharing Plus API
- **Platforms**: Twitter, Instagram, LinkedIn, Facebook
- **Content Types**: Text, images, links

### 7. Image and Network APIs
#### Cached Network Image API
- **Purpose**: Image caching and loading
- **Features**: 
  - Automatic caching
  - Loading placeholders
  - Error handling

#### HTTP API
- **Purpose**: Custom API calls
- **Methods**: GET, POST, PUT, DELETE
- **Used for**: Spotify API, Lyrics API

### 8. Audio Player APIs
#### Just Audio API
- **Purpose**: Primary audio playback
- **Features**:
  - Stream audio from URLs
  - Position/duration tracking
  - Background playback
  - Playlist management

#### Audioplayers API
- **Purpose**: Secondary audio support
- **Features**:
  - Local/remote audio playback
  - Multiple audio formats
  - Platform-specific optimizations

### 9. Support and External Links
#### Spotify Support
- **URL**: `https://support.spotify.com/us/`
- **Purpose**: User support and help documentation

#### Image Placeholder Services
- **Pinterest CDN**: Various album cover images
  - `https://i.pinimg.com/originals/...`
- **Placeholder**: `https://via.placeholder.com/{size}`

### 10. Development and Documentation APIs
#### Flutter Documentation
- **Dart Dev**: `https://dart.dev/tools`, `https://dart.dev/lints`
- **Flutter Dev**: `https://docs.flutter.dev/`
- **Android Developer**: `https://developer.android.com/`

## 📊 API Usage Statistics và Limits

### Firebase Quotas
- **Firestore**: 50,000 reads/day (free tier)
- **Storage**: 5GB storage, 1GB/day downloads
- **Authentication**: Unlimited

### Spotify API Limits
- **Rate Limiting**: 100 requests/minute
- **Client Credentials**: Extended rate limits
- **Preview Playback**: 30-second clips only

### External Services
- **LRCLib**: No official rate limits
- **Social APIs**: Platform-specific limits

## 🗄️ Database Structure

### Firebase Collections
1. **Users** collection:
   - User profile data
   - Authentication methods
   - Favorites subcollection
   - Playlists subcollection

2. **Songs** collection:
   - Song metadata (title, artist, album, genre)
   - Audio file URLs (Firebase Storage)
   - Cover image URLs
   - Upload information (addedBy, addedAt)
   - File size và platform info

3. **Playlists** subcollection:
   - Playlist metadata
   - Song IDs array
   - Cover image URL
   - Creation và update timestamps

## 🔐 Security và Permissions

### Firebase Security Rules
- **Authentication required** for user data
- **Owner-only access** for playlists và favorites
- **Admin permissions** for song uploads
- **File type validation** in storage rules

### App Permissions
- **Internet access** (networking)
- **Storage access** (file selection)
- **Camera access** (image capture)
- **Audio playback** permissions

## 📈 Scalability Features

### Architecture
- **Clean Architecture** với domain/data layers
- **Repository pattern** for data access
- **Use case pattern** for business logic
- **Service locator** for dependency injection

### Future Extensibility
- **Modular structure** for new features
- **Plugin architecture** ready
- **Multiple audio sources** support
- **Internationalization** ready structure

Tóm lại, Sporify là một ứng dụng music streaming hoàn chỉnh với đầy đủ tính năng từ authentication, audio playback, social features, admin panel upload nhạc, và tích hợp Spotify API. Dự án sử dụng công nghệ hiện đại với Flutter/Firebase stack và có khả năng mở rộng tốt.
