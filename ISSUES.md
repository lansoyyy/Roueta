# Roueta App - Known Issues

This document outlines all known issues in the Roueta bus tracking application.

---

## 1. Bus ETA is Simulated, Not Real

**Severity:** High  
**Category:** Core Functionality  
**Affected Files:**
- [`lib/screens/route_map_screen.dart`](lib/screens/route_map_screen.dart)
- [`lib/screens/active_bus_screen.dart`](lib/screens/active_bus_screen.dart)

### Description
The ETA (Estimated Time of Arrival) displayed to passengers is completely simulated using timers, not calculated from actual bus location data.

### Technical Details

#### In `route_map_screen.dart`:
- Uses `_simulateApproach()` method
- Implements `Timer.periodic` that counts down `_nearestMinutes` every 20 seconds
- No actual GPS-to-bus-stop distance calculation
- The countdown is purely artificial and doesn't reflect real bus movement

#### In `active_bus_screen.dart`:
- Uses `_startSimulation()` method
- Implements `Timer.periodic` every 30 seconds
- Fakes stop-by-stop progress without real location data
- No correlation with actual bus position

### Impact
- Passengers receive inaccurate arrival times
- No real-time tracking capability
- Cannot provide reliable service information

### Required Fix
- Implement real-time GPS tracking from driver's device
- Calculate ETA based on actual distance, speed, and traffic conditions
- Use Google Maps Distance Matrix API or similar for accurate estimates

---

## 2. No Real-Time Bus Location on Map

**Severity:** High  
**Category:** Core Functionality  
**Affected Files:**
- All map screens (`main_map_screen.dart`, `route_map_screen.dart`)

### Description
The map displays no real bus markers showing actual bus positions. The driver's GPS coordinates are never broadcast to the passenger's map view.

### Technical Details
- No bus markers are rendered on any GoogleMap widgets
- Driver location updates are not shared across devices
- No mechanism exists to display bus positions in real-time
- Map only shows static user location and route polylines

### Impact
- Passengers cannot see where buses actually are
- Cannot make informed decisions about which bus to board
- Core value proposition of a bus tracking app is missing

### Required Fix
- Implement real-time location sharing from driver to server
- Add bus markers to map widgets that update dynamically
- Use WebSocket or Firebase Realtime Database for live updates
- Add visual indicators for bus direction and status

---

## 3. No Backend / Cross-Device Sync

**Severity:** Critical  
**Category:** Architecture  
**Affected Files:**
- [`lib/providers/app_provider.dart`](lib/providers/app_provider.dart)

### Description
All application data (occupancy, route status, bus position) exists only in local device memory. There is no backend server or synchronization mechanism between devices.

### Technical Details
- All state is managed in `AppProvider` (local in-memory state)
- No Firebase, WebSocket, or REST API integration
- No database for persistent cross-device data storage
- Passenger on one phone sees nothing from driver updates on another phone
- Data is lost when app is closed

### Impact
- Complete lack of multi-user functionality
- Driver actions don't reach passengers
- No real-time collaboration possible
- App is essentially a single-device demo

### Required Fix
- Implement backend infrastructure (Firebase, Supabase, or custom server)
- Add real-time database for state synchronization
- Implement user authentication and session management
- Add offline support with data sync when connection restored

---

## 4. Driver Authentication is Hardcoded

**Severity:** Medium  
**Category:** Security  
**Affected Files:**
- [`lib/providers/auth_provider.dart`](lib/providers/auth_provider.dart)

### Description
Driver authentication uses 5 hardcoded fake accounts instead of a real authentication system.

### Technical Details
- Hardcoded credentials in `AuthProvider`:
  - `driver01/roueta123`
  - `driver02/roueta123`
  - `driver03/roueta123`
  - `driver04/roueta123`
  - `driver05/roueta123`
- No password hashing
- No session management
- No token-based authentication
- No password reset functionality

### Impact
- Security vulnerability - anyone with source code knows credentials
- No real user management
- Cannot scale to real deployment
- No audit trail of driver activities

### Required Fix
- Implement Firebase Authentication or similar
- Add secure password storage with hashing
- Implement JWT token-based sessions
- Add password reset functionality
- Create admin panel for user management

---

## 5. Notifications Screen Shows Fake Demo Data

**Severity:** Low  
**Category:** UX  
**Affected Files:**
- [`lib/screens/notifications_screen.dart`](lib/screens/notifications_screen.dart)

### Description
The notifications screen displays 7 hardcoded `_NotifItem` objects instead of real, triggered notifications.

### Technical Details
- 7 pre-filled notification objects in `notifications_screen.dart`
- Notifications are static and never update
- No connection to actual app events
- No notification history from real triggers
- Demo data includes fake timestamps and messages

### Impact
- Misleading user experience
- Users see notifications that don't correspond to real events
- Cannot track actual notification history

### Required Fix
- Store notifications in backend database
- Link notifications to real app events (bus arriving, route changes, etc.)
- Implement real-time notification updates
- Add notification read/unread status tracking

---

## 6. Feedback Form Does Nothing

**Severity:** Low  
**Category:** Functionality  
**Affected Files:**
- [`lib/screens/help_feedback_screen.dart`](lib/screens/help_feedback_screen.dart)

### Description
The feedback submission only sets a local flag (`_submitted = true`) and doesn't actually send the feedback anywhere.

### Technical Details
- `_submit()` method only updates local state
- No API call to backend
- No email integration
- Feedback data is lost when screen is closed
- No confirmation email sent to user

### Impact
- User feedback is never received
- No way to collect user input for improvements
- Users may think feedback was submitted when it wasn't

### Required Fix
- Integrate with backend API to store feedback
- Add email notification for support team
- Implement feedback acknowledgment to user
- Add feedback categories and priority levels

---

## 7. Settings Save But Have Zero Real Effect

**Severity:** Medium  
**Category:** UX/Functionality  
**Affected Files:**
- [`lib/screens/settings_screen.dart`](lib/screens/settings_screen.dart)
- [`lib/providers/app_provider.dart`](lib/providers/app_provider.dart)
- All map screens

### Description
All settings are persisted using SharedPreferences but are never read back to control app behavior.

### Technical Details

#### Affected Settings:
1. **Map Type (Normal/Satellite/Terrain/Hybrid)**
   - Saved to SharedPreferences
   - Never passed to `mapType:` parameter on any GoogleMap widget

2. **Show Traffic Layer**
   - Saved to SharedPreferences
   - Never passed to `trafficEnabled:` on any GoogleMap widget

3. **Language (English/Filipino/Cebuano)**
   - Saved to SharedPreferences
   - No i18n/l10n implementation anywhere in the app

4. **Default Mode**
   - Saved to SharedPreferences
   - Not applied on app launch

5. **High Accuracy Mode**
   - Saved to SharedPreferences
   - `_getCurrentLocation()` always uses `LocationAccuracy.high` regardless

6. **Auto-Center on Location**
   - Saved to SharedPreferences
   - Map never auto-centers on user location

7. **Vibration**
   - Saved to SharedPreferences
   - Never wired to notification delivery

### Impact
- Settings UI is deceptive - changes have no effect
- Users waste time configuring options that don't work
- Poor user experience and trust issues

### Required Fix
- Read settings from SharedPreferences on app startup
- Apply map type to all GoogleMap widgets
- Implement internationalization (i18n) for language support
- Connect traffic toggle to map traffic layer
- Implement auto-center functionality
- Wire vibration to notification service

---

## 8. Occupancy & Route Status Notifications Never Fire

**Severity:** Medium  
**Category:** Features  
**Affected Files:**
- [`lib/services/notification_service.dart`](lib/services/notification_service.dart)
- [`lib/screens/settings_screen.dart`](lib/screens/settings_screen.dart)

### Description
The `NotificationService` only implements `showBusApproachingNotification()`. No implementation exists for occupancy update or route status change notifications, even though toggle settings exist for them in settings.

### Technical Details
- `NotificationService` has only one method: `showBusApproachingNotification()`
- Settings screen includes toggles for:
  - Occupancy notifications
  - Route status change notifications
- No methods to trigger these notifications
- No listeners for occupancy or route status changes

### Impact
- Settings suggest features that don't exist
- Users won't be notified of important changes
- Missed opportunity for user engagement

### Required Fix
- Implement `showOccupancyNotification()` method
- Implement `showRouteStatusNotification()` method
- Add listeners to occupancy and route status changes
- Wire notification toggles to actual notification triggers

---

## 9. Driver "Assigned Routes" Shows All Routes, Not the Driver's Routes

**Severity:** Medium  
**Category:** Logic  
**Affected Files:**
- [`lib/screens/driver/my_routes_screen.dart`](lib/screens/driver/my_routes_screen.dart)

### Description
The `_AssignedRoutesTab` displays `provider.routes` (every single route) instead of filtering to routes assigned to that specific driver/badge.

### Technical Details
- `_AssignedRoutesTab` iterates over `provider.routes`
- No filtering logic based on driver ID or badge
- All drivers see all routes
- No actual route assignment system exists

### Impact
- Drivers see routes they're not assigned to
- Cannot manage specific route assignments
- Confusing UI for drivers

### Required Fix
- Add route assignment data structure
- Filter routes based on driver ID/badge
- Implement admin interface for route assignment
- Add route assignment to backend database

---

## 10. Driver Profile "Trip History" Button Goes to Wrong Screen

**Severity:** Low  
**Category:** UX  
**Affected Files:**
- [`lib/screens/profile_screen.dart`](lib/screens/profile_screen.dart)

### Description
The "Trip History" menu item navigates to `MyRoutesScreen()` (same as "My Routes") instead of opening the Trip History tab.

### Technical Details
- Navigation logic incorrectly routes to `MyRoutesScreen()`
- Should navigate to a Trip History screen or tab
- No dedicated Trip History screen exists
- Same destination as "My Routes" menu item

### Impact
- Users cannot access trip history
- Confusing navigation - two buttons go to same place
- Missing feature that appears to exist

### Required Fix
- Create dedicated Trip History screen
- Update navigation to correct screen
- Implement trip history tracking in backend
- Add trip history data display

---

## 11. startLiveTracking() Leaks a Stream

**Severity:** Medium  
**Category:** Memory/Performance  
**Affected Files:**
- [`lib/providers/app_provider.dart`](lib/providers/app_provider.dart)

### Description
In `AppProvider`, `startLiveTracking()` calls `.listen()` but never stores the `StreamSubscription`, so it can never be cancelled/disposed.

### Technical Details
- `startLiveTracking()` creates a stream listener
- No `StreamSubscription` object is stored
- No way to cancel the subscription
- Leads to memory leak when provider is disposed
- Location updates continue even after app is closed

### Impact
- Memory leak causes performance degradation
- Battery drain from continuous location updates
- Potential crashes from accumulated subscriptions
- Poor resource management

### Required Fix
- Store `StreamSubscription` in a class variable
- Implement proper disposal in `dispose()` method
- Cancel subscription when tracking stops
- Add lifecycle management for location streams

---

## 12. Occupancy in Route Map Starts as Hardcoded Stale Data

**Severity:** Low  
**Category:** Data  
**Affected Files:**
- [`lib/screens/route_map_screen.dart`](lib/screens/route_map_screen.dart)

### Description
In `route_map_screen.dart`, `_routeOccupancy` is initialized to `OccupancyStatus.limitedSeats` and `_occupancyLastUpdated` is hardcoded to 8 minutes ago, always showing a stale "Limited Seats" warning before any driver sets anything.

### Technical Details
- `_routeOccupancy` initialized to `OccupancyStatus.limitedSeats`
- `_occupancyLastUpdated` hardcoded to 8 minutes ago
- No real-time occupancy data fetching
- Stale data displayed until driver manually updates

### Impact
- Misleading occupancy information
- Users see warnings that may not be accurate
- Poor first impression when opening route map

### Required Fix
- Initialize with `OccupancyStatus.unknown` or fetch real data
- Implement real-time occupancy updates from backend
- Show loading state while fetching initial data
- Add timestamp for last update

---

## 13. Map Tab (Center Button) is Bare

**Severity:** Medium  
**Category:** Features  
**Affected Files:**
- [`lib/screens/main_map_screen.dart`](lib/screens/main_map_screen.dart)

### Description
The "ROUTES" center button's map view shows only a plain Google Map with user location. No bus markers, no route overlays, no stop markers.

### Technical Details
- Map displays only user location marker
- No bus position markers
- No route polyline overlays
- No bus stop markers
- Essentially an empty map with minimal functionality

### Impact
- Wasted screen real estate
- Users expect to see routes and buses on main map
- Poor user experience for core feature

### Required Fix
- Add bus markers for all active buses
- Draw route polylines for all routes
- Add bus stop markers with labels
- Implement clustering for multiple markers
- Add legend for map elements

---

## 14. Driver "On Duty" Badge is Always Shown

**Severity:** Low  
**Category:** UX  
**Affected Files:**
- [`lib/screens/driver/my_routes_screen.dart`](lib/screens/driver/my_routes_screen.dart)

### Description
The info strip in `_AssignedRoutesTab` always displays "On Duty" regardless of the driver's actual active state.

### Technical Details
- Badge text is hardcoded to "On Duty"
- No connection to driver's actual status
- No toggle or state management for duty status
- Visual indicator doesn't reflect reality

### Impact
- Misleading status display
- No way to indicate when driver is off duty
- Poor communication of driver availability

### Required Fix
- Add duty status state to driver profile
- Implement toggle for on/off duty
- Update badge based on actual status
- Sync duty status to backend

---

## Summary Statistics

| Severity | Count | Issues |
|----------|-------|--------|
| Critical | 1 | No Backend / Cross-Device Sync |
| High | 2 | Bus ETA is Simulated, No Real-Time Bus Location |
| Medium | 6 | Driver Auth Hardcoded, Settings No Effect, Notifications Never Fire, Assigned Routes Wrong, Stream Leak, Map Tab Bare |
| Low | 5 | Fake Notifications, Feedback Does Nothing, Trip History Wrong, Stale Occupancy Data, Always On Duty Badge |

**Total Issues:** 14

---

## Recommended Priority Order

1. **Critical:** Implement backend infrastructure (Issue #3)
2. **High:** Real-time bus location tracking (Issue #2)
3. **High:** Real ETA calculation (Issue #1)
4. **Medium:** Fix stream subscription leak (Issue #11)
5. **Medium:** Implement real authentication (Issue #4)
6. **Medium:** Make settings functional (Issue #7)
7. **Medium:** Add map features to main screen (Issue #13)
8. **Medium:** Implement occupancy/route notifications (Issue #8)
9. **Medium:** Fix assigned routes filtering (Issue #9)
10. **Low:** Fix trip history navigation (Issue #10)
11. **Low:** Fix initial occupancy data (Issue #12)
12. **Low:** Implement real notifications (Issue #5)
13. **Low:** Implement feedback submission (Issue #6)
14. **Low:** Fix on-duty badge (Issue #14)

---

*Last Updated: March 13, 2026*
