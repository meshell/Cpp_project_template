#ifdef _WINDOWS
#include <ciso646>
#endif
#include <catch/catch.hpp>
#include "dummy.h"

namespace {

using CppTemplate::Dummy;

TEST_CASE("A newly created default dummy", "[creation]")
{
      Dummy dummy{};
      REQUIRE(dummy.speechless());
}

TEST_CASE("A english dummy", "[creation]")
{
      Dummy dummy{"Hello", "World"};

      REQUIRE(not dummy.speechless());
      REQUIRE(dummy.say_hello() == "Hello World");
}

} //namespace
