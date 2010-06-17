use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Template::Object',
    VERSION_FROM      => 'lib/Template/Object.pm', # finds $VERSION
    PREREQ_PM         => { 'Class::Data::Accessor' => 0.04004 },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Template/Object.pm', # retrieve abstract from module
       AUTHOR         => 'Ivan Fomichev <ifomichev@cpan.org>') : ()),
);
