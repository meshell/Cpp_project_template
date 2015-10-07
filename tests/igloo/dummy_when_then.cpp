#include <string>
#include <igloo/igloo_alt.h>
#include "dummy.h"

using CppTemplate::Dummy;
using namespace igloo;


namespace {

When (New_default_dummy_is_created)
{
    Then(it_should_be_speechless)
    {
        Assert::That(dummy.speechless(), Is().EqualTo(true));
    }

    Dummy dummy{};
};

When (A_english_dummy_is_created)
{
    void SetUp () override
    {
        dummy.reset(new Dummy{"Hello", "World"});
    }

    Then(it_should_not_be_speechless)
    {
        Assert::That(dummy->speechless(), Is().Not().EqualTo(true));
    }

    Then(it_should_speak_english)
    {
        Assert::That(dummy->say_hello(), Is().EqualTo("Hello World"));
    }

    std::unique_ptr<Dummy> dummy{};

};

} //namespace
