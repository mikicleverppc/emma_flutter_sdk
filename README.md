# emma_flutter_sdk

This SDK contains EMMA flutter native bindings

https://www.emma.io

For more information about EMMA sdk you can go to https://support.emma.io

## Package

Package is published on https://pub.dev/packages/emma_flutter_sdk

## Configuration

You can check `/example` folder for a complete EMMA flutter sdk implementation. There is some divergences about native implementation listed here

### Push System

#### Android

On Android you must include notification icon as a drawable.

1. Open Runner in Android Studio
2. Put your icon files inside `/app/res/drawable` folder into your Android Studio project

## Current Implementation

- [x] Session Tracking (Start Session)
- [x] Event Tracking
- [x] Update User Profile
- [ ] Default events
  - [x] Login
  - [x] Register
  - [ ] Purchase
- [ ] Powlink Support
- [x] Push System Support
  - [x] Receive Push
  - [ ] Notification Color
  - [x] Mark push as opened
  - [x] Rich Push
- [x] Native Ads
- [ ] InApp Messages
  - [x] Start View
  - [ ] Banner
  - [ ] AdBall
  - [ ] Dynamic Tab
  - [ ] Coupon
  - [ ] Strip
  