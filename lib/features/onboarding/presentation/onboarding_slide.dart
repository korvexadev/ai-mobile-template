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
    title: 'Access the latest and hottest news',
    description: 'The stories that matter, arranged with clarity.',
    artwork: OnboardingArtwork.frontPage,
  ),
  OnboardingSlide(
    title: 'Made with entertainment at its core.',
    description:
        'Mikozi issues a balance between storytelling and entertainment',
    artwork: OnboardingArtwork.reading,
  ),
  OnboardingSlide(
    title: 'Enjoy the latest',
    description: 'Be updates with the stories that matter',
    artwork: OnboardingArtwork.collection,
  ),
];
