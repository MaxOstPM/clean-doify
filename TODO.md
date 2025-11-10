# TODO — clean-doify (iOS)
Short description: Preparation & scaffolding plan for the MVP.

## 0) Pre-flight (Day 0, must-do)
- [ ] Define app identifiers (bundle id, display name, team) — **High**
- [ ] Choose architecture (<MVVM + Coordinators|TCA/Redux>), DI strategy — **High**
- [ ] Decide package manager (prefer **SwiftPM**) — **High**
- [ ] Define environments (dev/stg/prod), scheme strategy, config files — **High**
- [ ] Establish design tokens source (typography, colors, spacing) — **High**
- [ ] Versioning policy (SemVer + build number) — **High**

## 1) Repo & Project Scaffolding
- [ ] Create repo with `main` + `develop`, protect branches — **High**
- [ ] Add `.gitignore` for Xcode/DerivedData/user settings — **High**
- [ ] Initialize Xcode project (SwiftUI lifecycle, iOS min), targets: App/Unit/UITests — **High**
- [ ] Create shared schemes: App-Dev / App-Stg / App-Prod — **High**
- [ ] Build configs: Debug / Staging / Release — **High**
- [ ] Enable only necessary capabilities (Push/Keychain/App Groups/etc.) — **Med**

## 2) Configuration & Secrets
- [ ] Add `Configs/` with base + per-env **.xcconfig** (API_URL, FEATURE_FLAGS, LOG_LEVEL) — **High**
- [ ] Secrets policy: never commit; use CI env vars / encrypted files — **High**
- [ ] App Transport Security (ATS) review; pin TLS; minimal exceptions — **Med**
- [ ] Fill `Info.plist` privacy strings (camera/microphone/photos/location) — **High**

## 3) Dependencies (lean & stable)
- [ ] Add SwiftPM baseline (only used packages) — **High**
- [ ] Logging wrapper (swift-log or thin façade) — **Med**
- [ ] Networking with URLSession + async/await (avoid Alamofire unless needed) — **High**
- [ ] JSON decoding strategies (dates/decimals) — **Med**
- [ ] Image loader (Nuke/Kingfisher) if remote images — **Low**
- [ ] Feature flags/Remote Config (Firebase RC or LaunchDarkly) — **Med**
- [ ] Analytics/Crash (Crashlytics + Analytics OR Sentry + Amplitude) — **High**

## 4) Architecture Skeleton
- [ ] Create folders:
  - App/ (AppMain.swift, CompositionRoot/)
  - Core/ (Networking/, Persistence/, Analytics/, Logging/, DesignSystem/, Utilities/)
  - Features/ (Onboarding/, Home/, Settings/)
  - Resources/ (Localization/, Assets.xcassets, Config/)
  - Tests/ (Unit/, UI/)
- [ ] Navigation: Coordinator/Router (or TCA Navigation) with typed routes — **High**
- [ ] State mgmt: choose and document (<MVVM|TCA|Redux>) — **High**
- [ ] DI: Composition Root wiring services (APIClient, Auth, Persistence, Analytics) — **High**

## 5) Core Services
- [ ] API Client: request builder, interceptors (auth, retry/backoff), decoding — **High**
- [ ] Error model: map RFC-7807-like payloads → domain errors + user-safe messages — **High**
- [ ] Persistence: <SwiftData|Core Data|FileStore>, define migration policy — **Med**
- [ ] Auth service: Keychain token store, refresh flow — **High**
- [ ] Analytics façade: typed events, privacy-aware — **Med**

## 6) Design System (MVP)
- [ ] Define tokens: colors, typography scale, spacing, radii, shadows — **High**
- [ ] Base components: Button, TextField, Card, Chip, ListRow, EmptyState — **Med**
- [ ] Theme: Light/Dark; high-contrast considerations — **Med**
- [ ] Iconography: SF Symbols mapping rules — **Low**

## 7) Quality Gates
- [ ] Add SwiftFormat + SwiftLint configs; pre-commit hook — **High**
- [ ] Unit tests: Core (Networking/Parsing/Reducers or ViewModels) — **High**
- [ ] Snapshot/UI tests for first critical screens — **Med**
- [ ] Treat warnings as errors (with allowlist) — **Med**
- [ ] Baseline performance metrics (launch time, memory) — **Low**

## 8) CI/CD
- [ ] GitHub Actions: build per scheme; lint/format; unit tests with coverage ≥ 60% Core — **High**
- [ ] Fastlane: `test`, `beta`, `release`; auto build-number; changelog from conventional commits — **High**
- [ ] dSYM upload to Crash platform — **High**
- [ ] Provisioning: automatic signing / match; App Store Connect app record — **High**

## 9) Observability, Privacy, Compliance
- [ ] Crash + logs integrated behind façade — **High**
- [ ] Key app metrics (cold start, screen time, core funnel) — **Med**
- [ ] Consent gating (GDPR/CCPA); analytics opt-out — **High**
- [ ] Permissions UX: pre-prompt education; graceful degradation — **Med**

## 10) Product Ops
- [ ] Feature flags for risky work; kill-switches — **High**
- [ ] Remote Config for text/URLs/A-B toggles — **Med**
- [ ] In-App Review heuristics (SKStoreReviewController) — **Low**
- [ ] Push notifications setup (if needed): APNs keys, token registration — **Low**
- [ ] Localization baseline: EN + primary locale; string audit — **Med**

## 11) Release Readiness (pre-TestFlight)
- [ ] App Icon + Launch Screen polished — **High**
- [ ] Accessibility pass (labels, traits, hit targets, contrast, Dynamic Type) — **High**
- [ ] Offline behavior: minimal caching + empty states — **Med**
- [ ] Settings: version, privacy, terms, contact — **Med**
- [ ] Legal docs hosted; ATT (if ads/tracking) — **High**

## Suggested Order of Execution
1) Repo + Xcode + schemes/configs  
2) Design tokens + base UI components  
3) Core (Networking, Error model, Analytics façade)  
4) DI + Navigation skeleton  
5) First feature end-to-end (Onboarding/Home)  
6) Lint/Format + Unit tests  
7) CI + Fastlane + Crash/Analytics  
8) A11y & empty states → TestFlight

## ADRs to Draft
- ADR-001: State management choice
- ADR-002: DI approach & lifetimes
- ADR-003: Networking stack & error model
- ADR-004: Persistence strategy & migration policy
- ADR-005: Feature flag / Remote Config vendor

## Acceptance Criteria
- `TODO.md` renders with checkboxes and priorities.
- No ambiguous tasks; each item is independently actionable.
- Sections match this outline; links/code blocks render correctly.
- File is idempotent and safe to run repeatedly (docs-only).
- Ready for immediate use in PR checklist.

## Change Log
- v0.1 Initial scaffolding checklist for clean-doify.
