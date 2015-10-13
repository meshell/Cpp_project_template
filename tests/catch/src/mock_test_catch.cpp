#ifdef _WINDOWS
#include <ciso646>
#endif
#include <gmock/gmock.h>
#include <catch/catch.hpp>


class IFoo
{
public:
  virtual ~IFoo() {}
  virtual void foo() const = 0;
  virtual void bar() const = 0;
};


class MockFoo : public IFoo
{
public:
  MOCK_CONST_METHOD0(foo, void());
  MOCK_CONST_METHOD0(bar, void());
};

class Testee
{
public:
  explicit Testee(const IFoo& foo)
    : my_foo(foo)
  {
  }

  void call_foo () const
  {
    my_foo.foo();
  }

private:
  const IFoo& my_foo;
};

/*
This test is used to show google mock in action
*/
namespace {

TEST_CASE("Call expectations can be set on a Mock", "[mock]")
{
	MockFoo foo{};
	Testee testee{foo};
	EXPECT_CALL(foo, foo());

	testee.call_foo();
	SUCCEED();
}

SCENARIO("Using Google Mock in catch", "[mock]")
{
  GIVEN("A Mock class")
  {
    MockFoo foo{};
    Testee testee{foo};

    EXPECT_CALL(foo, foo());
    EXPECT_CALL(foo, bar()).Times(0);

    WHEN("the method foo is called on the mock")
    {
      testee.call_foo();
      THEN("a call to foo is expected")
      {
        REQUIRE(::testing::Mock::VerifyAndClearExpectations(&testee));
      }

      THEN("a call to bar is not expected")
      {
        REQUIRE(::testing::Mock::VerifyAndClearExpectations(&testee));
      }
    }
  }
}

} //namespace