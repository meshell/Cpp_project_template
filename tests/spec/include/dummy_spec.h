#ifndef DUMMYSPEC_H_
#define DUMMYSPEC_H_

#include "CppSpec/CppSpec.h"
#include "dummy.h"

using CppTemplate::Dummy;

class DefaultDummySpec:
  public CppSpec::Specification<Dummy, DefaultDummySpec>
{
  public:
  DefaultDummySpec()
  {
    REGISTER_BEHAVIOUR(DefaultDummySpec, isSpeechless);
  }

  void isSpeechless ();

};


class EnglishDummySpec :
  public CppSpec::Specification<Dummy, EnglishDummySpec>
{
  public:
  EnglishDummySpec()
  {
    REGISTER_BEHAVIOUR(EnglishDummySpec, is_not_speechless);
    REGISTER_BEHAVIOUR(EnglishDummySpec, speaks_english);
  }

  Dummy* createContext();

  void is_not_speechless ();

  void speaks_english ();

};

#endif // DUMMYSPEC_H_
