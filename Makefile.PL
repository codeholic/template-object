use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Template::Object',
    VERSION_FROM      => 'lib/Template/Object.pm',
    PREREQ_PM         => {
        'Class::Data::Accessor' => 0.04004,
        'Test::More'            => 0.94,
    },
    ABSTRACT_FROM     => 'lib/Template/Object.pm',
    AUTHOR            => 'Ivan Fomichev <ifomichev@cpan.org>',
);
