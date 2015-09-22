#ifdef _WINDOWS
#include <ciso646>
#endif
#include <catch/catch.hpp>
#include "dummy.h"

using CppTemplate::Dummy;

namespace {

SCENARIO("Default dummy", "[creation]")
{
    GIVEN("A default dummy")
    {
        Dummy dummy;

        WHEN("the dummy wants to speak")
        {
            THEN("the dummy is speechless")
            {
                REQUIRE(dummy.speechless());
            }
        }
    }
}

SCENARIO("English dummy", "[creation]")
{
    GIVEN("A english dummy")
    {
        Dummy dummy{"Hello", "World"};

        WHEN("the dummy speak")
        {
            THEN("the dummy speaks english")
            {
                REQUIRE(not dummy.speechless());
                REQUIRE(dummy.say_hello() == "Hello World");
            }
        }
    }
}

} //namespace
