# AgriAI — Climate-Smart Farming & Market Advisor

## Core Loop
Farmers photograph diseased leaves or pest damage; the app identifies the problem, suggests a locally available treatment, and shows nearby market prices — while a native-language agent answers follow-up questions in Sinhala, Tamil, or English instead of making the farmer navigate menus.

## Future-Proof Edge
It solves the two hardest adoption barriers in South Asian agri-tech at once — climate unpredictability (localized weather/rainfall alerts) and digital-literacy gaps (conversational agent) — rather than picking one.

## Architecture
- **Frontend**: Flutter (Drift for offline SQLite, Riverpod state, GoRouter)
- **ML**: On-device TensorFlow Lite for offline disease detection
- **Backend**: FastAPI with an SSE-streaming agent (OpenAI), plus weather and market-price integrations

## Team Roles (7-Person Build)
1. **Mobile UI/navigation lead** — screen consistency, GoRouter flows, polish
2. **Camera & on-device ML engineer** — wire the TFLite model into the camera scan screen, build the disease-result UI
3. **Conversational agent engineer** — extend the chat agent, tune Sinhala/Tamil responses, harden the SSE stream
4. **Backend/API engineer** — move the agent off localhost into a real deployable service with auth
5. **Data & integrations engineer** — weather API, market price board, supplier/location mapping
6. **Offline & sync engineer** — harden Drift storage, background sync, conflict handling on reconnect
7. **QA/DevOps + team lead** — cross-device testing, CI, sprint coordination, demo prep

## Design Patterns (SE205.3)
- **Repository** for the data-access layer.
- **Strategy** for swapping the online/offline data source or AI provider.
- **Factory** for constructing alert types (weather vs. disease vs. price).
- **Observer** for triggering notifications when new alerts come in.
