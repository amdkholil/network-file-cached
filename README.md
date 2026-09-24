# Network File Cacher

A Flutter package to download and cache files locally using `dio` and `hive`.

## Supported Platforms

- **Android**
- **iOS**
- **macOS**
- **Windows**
- **Linux**

*(Note: Web platform is not supported as this package requires native file system access provided by `dart:io`).*

## Features

- Download and cache files locally in temporary storage.
- Auto-expiration mechanism for cached files (default: 12 hours).
- Automatic MIME type detection to resolve original file extensions.
- Support for progress tracking during download.
- Fast local lookup backed by Hive KV database.

## Installation

Add dependency to your `pubspec.yaml`:

```yaml
dependencies:
  network_file_cacher: ^1.0.0
```

## Initialization

Initialize `NetworkFileCacher` before downloading files (typically in `main()`):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkFileCacher.init(expired: const Duration(hours: 12));
  runApp(const MyApp());
}
```

## Usage

### Simple Usage with `FutureBuilder`

```dart
FutureBuilder<File>(
  future: NetworkFileCacher.downloadFile('https://example.com/sample.pdf'),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (snapshot.hasData) {
      return Image.file(snapshot.data!);
    }
    return const SizedBox();
  },
)
```

### Download with Progress Tracking

```dart
File? file;
double progress = 0;

void loadFile(String url) async {
  try {
    final downloadedFile = await NetworkFileCacher.downloadFile(
      url,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          setState(() {
            progress = (received / total) * 100;
          });
        }
      },
    );
    setState(() {
      file = downloadedFile;
    });
  } catch (e) {
    debugPrint('Download error: $e');
  }
}
```
