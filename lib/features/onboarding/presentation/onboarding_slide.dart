enum OnboardingArtwork { frontPage, reading, collection }

final class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.artwork,
  });

  final OnboardingArtwork artwork;
  final String description;
  final String title;
}

const onboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    title: 'News, without the noise.',
    description: 'The stories that matter, arranged with clarity.',
    artwork: OnboardingArtwork.frontPage,
  ),
  OnboardingSlide(
    title: 'Made for reading.',
    description: 'Quiet typography, generous space, and every word in focus.',
    artwork: OnboardingArtwork.reading,
  ),
  OnboardingSlide(
    title: 'Keep your world close.',
    description: 'Follow sections and return to stories when you are ready.',
    artwork: OnboardingArtwork.collection,
  ),
];
