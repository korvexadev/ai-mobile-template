# Mikozi Mobile Design Direction

Mikozi combines the editorial clarity of Apple News with the content hierarchy
shown in eider.design's “Modern News App UI”. It is an original system, not a
pixel copy.

## Visual character

- Near-black ink, warm paper white, restrained cool gray, Mikozi red for
  navigation/action, and a sparing deep blue for informational states.
- Large editorial headlines, compact metadata, comfortable article body
  leading, and few type styles with obvious hierarchy.
- Edge-to-edge publication imagery balanced by quiet list rows and deliberate
  white space.
- Publisher/source identity, section, timestamp, correction, and sponsorship
  labels remain legible without competing with the headline.
- Rounded surfaces are reserved for filters, media, and grouped controls—not
  placed around every piece of content.
- No ornamental gradients, glass overlays, excessive shadows, or generic
  dashboard cards.
- Manrope carries interface and editorial display text, matching the homepage
  reference's clean, rounded grotesk character. It is bundled so first-run and
  offline reading never depend on a font download.

## Reference-library use

- `assets/design/` is source material for hierarchy, image rhythm, compact
  navigation, editorial typography, and white-space decisions.
- Reference screenshots are never bundled into the released application or
  presented as Mikozi content.
- Splash, onboarding, authentication, and reading surfaces use original
  code-native compositions built from the Mikozi mark and design tokens.

## Navigation and interaction

- Native adaptive tab/navigation structures anchor Today, Discover, Saved, and
  Profile.
- The homepage keeps its brand, search, and notification actions pinned above
  the feed while content scrolls beneath. Lead media, category pills, compact
  story rows, and the floating reader navigation translate `home.png` without
  copying its fictional publisher content.
- Search and section filters remain close to discovery content.
- Authentication is a short, calm interruption: phone, code, optional profile,
  then return to the reader's pending destination.
- Profile is a reader-control surface for identity, preferences, privacy,
  history, notifications, sessions, and sign-out—not a social vanity page.
- Dynamic Type, VoiceOver semantics, reduced motion, contrast, reachability,
  safe areas, loading, offline, error, and retry states are first-class.

## Authentication screens

- Translate the login reference into a near-black patterned masthead and one
  quiet, rounded-top form surface. Preserve Mikozi's phone-only identity flow;
  do not add email, social login, or decorative actions from the reference.
- Phone entry uses one primary field, an explicit Malawi `+265` context, clear
  consent/support copy, and one dominant action.
- OTP verification uses six accessible digit positions backed by one semantic
  input, with resend timing and change-number actions.
- Profile uses grouped native settings rows and an editorial identity header.
- Tokens, OTP values, internal IDs, and provider errors never enter visible
  diagnostics.
- Auth headings use Manrope's confident interface weight. White space and the
  form's clear boundary carry hierarchy instead of explanatory paragraphs.

## Reference translation

The Dribbble reference contributes publisher rails, trending hierarchy,
breaking-news filters, clean article typography, and profile composition.
Apple guidance contributes content-first hierarchy, native navigation,
Dynamic Type, platform consistency, and accessible controls.

`home.png` contributes the pinned action layer, immersive lead card, compact
category pills, restrained gray story rows, and floating navigation. The
dashboard and backend remain authoritative for which section types appear and
their order.
