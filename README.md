# AgriAI — Climate-Smart Farming & Market Advisor

## Core Loop
Farmers photograph diseased leaves or pest damage; the app identifies the problem, suggests a locally available treatment, and shows nearby market prices — while a native-language agent answers follow-up questions in Sinhala, Tamil, or English instead of making the farmer navigate menus.

## Future-Proof Edge
It solves the two hardest adoption barriers in South Asian agri-tech at once — climate unpredictability (localized weather/rainfall alerts) and digital-literacy gaps (conversational agent) — rather than picking one.

## Architecture
- **Frontend**: Flutter (Drift for offline SQLite, Riverpod state, GoRouter)
- **ML**: On-device TensorFlow Lite for offline disease detection
- **Backend**: FastAPI with an SSE-streaming agent (OpenAI), plus weather and market-price integrations

## Development Roadmap & Modules
1. **Mobile UI & Navigation** — screen consistency, GoRouter flows, and overall polish.
2. **Camera & On-device ML** — wire the TFLite model into the camera scan screen and build the disease-result UI.
3. **Conversational Agent** — extend the chat agent, tune Sinhala/Tamil native-script responses, and harden the SSE stream.
4. **Backend & API** — move the agent off localhost into a deployable service with authentication.
5. **Data & Integrations** — weather API, market price board, and supplier/location mapping.
6. **Offline & Sync** — harden Drift SQLite storage, background sync, and conflict handling on reconnect.
7. **QA & Testing** — cross-device testing, continuous integration, and demo prep.

## Design Patterns (SE205.3)
- **Repository** for the data-access layer.
- **Strategy** for swapping the online/offline data source or AI provider.
- **Factory** for constructing alert types (weather vs. disease vs. price).
- **Observer** for triggering notifications when new alerts come in.
