use ExtUtils::MakeMaker;

WriteMakefile(
  PREREQ_PM => {
    'URI' => 0,
    'Furl' => 0,
    'Text::Iconv' => 0,
  },
);
