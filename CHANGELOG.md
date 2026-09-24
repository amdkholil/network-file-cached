## 1.1.0

* **Breaking / Renaming**: Renamed main class `NetworkFileCached` to `NetworkFileCacher` to align with package name.
* **Flutter Upgrade**: Upgrade Flutter SDK requirement and updated dependencies (`dio`, `crypto`, `mime`, `path`, `path_provider`, `flutter_lints`).
* **Concurrency Fix**: Resolved race conditions by removing static state variables in `downloadFile`.
* **Memory Optimization**: Improved MIME header inspection by reading stream up to 1024 bytes instead of entire file into memory.
* **Error Handling**: Improved Dio exception handling using modern `DioException`.
* **Example Project**: Re-generated example app with updated Flutter & Dio usage.

## 1.0.0 

* add header
* fix for long url (specialy for S3 url)

## 0.0.7

* Fix: Unknown hive register adapter

## 0.0.6

* Fix on receive progress
* Update example
* Update readme

## 0.0.5

* Update code on readme

## 0.0.4

* Update example

## 0.0.3

* Added some await future

## 0.0.2

* Lost file check.

## 0.0.1

* Initial release.
