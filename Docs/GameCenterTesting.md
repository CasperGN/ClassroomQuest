# Game Center Testing Checklist

Follow these steps to exercise achievements and leaderboards while developing ClassroomQuest.

## 1. App Store Connect setup

1. Create or open the ClassroomQuest app record in App Store Connect.
2. Enable **Game Center** for the app version you are testing.
3. Define the achievements and leaderboards used in the build:
   - `com.classroomquest.achievement.firstquest`
   - `com.classroomquest.achievement.tenquests`
   - `com.classroomquest.achievement.hundredcorrect`
   - `com.classroomquest.achievement.firstmastery`
   - `com.classroomquest.leaderboard.totalcorrect`
4. Download a provisioning profile that includes the `com.apple.developer.game-center` entitlement and install it locally.

Without this configuration the device will report `GKErrorDomain Code=15 (gameUnrecognized)`.

## 2. Xcode project configuration

1. Open **Signing & Capabilities** for the `ClassroomQuest` target.
2. Ensure **Game Center** is enabled and that the target uses `ClassroomQuest/ClassroomQuest.entitlements`.
3. Confirm the bundle identifier in the project matches the identifier configured in App Store Connect.

## 3. Sandbox tester account

1. In App Store Connect, invite a Sandbox Tester Apple ID (Users and Access → Sandbox Testers).
2. Accept the invitation via email, then sign in with that Apple ID under **Settings › Game Center** on the test device or simulator.
3. If you need to reset achievements, use **Settings › Game Center › ClassroomQuest › Reset Achievements**.

## 4. Launching the build

1. Install the build from Xcode onto the device or simulator that is signed into Game Center.
2. Launch the app. The Game Center sign-in sheet will appear automatically if credentials are required.
3. Once authenticated, the Game Center access point (top-left icon) can be toggled from the Parent Dashboard.
4. Complete quests to trigger the queued achievement and leaderboard submissions. The manager automatically replays pending reports after a successful sign-in.

## 5. Troubleshooting

| Symptom | Resolution |
| --- | --- |
| `The requested operation could not be completed because this application is not recognized by Game Center.` | Confirm Game Center is enabled for the bundle in App Store Connect and reinstall the build after downloading the updated provisioning profile. |
| `Please sign in to Game Center from Settings` | Open **Settings › Game Center** and sign in with the sandbox tester account, then relaunch ClassroomQuest. |
| `Game Center is restricted on this device.` | Check Screen Time or parental controls on the device and allow Game Center for the sandbox account. |
| No dashboard sheets appear | Game Center dashboards require iOS 17 or newer; on older systems achievements still report silently. |

Keep this checklist handy when preparing builds for review or QA to ensure achievements and leaderboards behave as expected.
