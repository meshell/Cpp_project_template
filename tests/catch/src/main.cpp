#define CATCH_CONFIG_RUNNER  // This tells Catch that a main() is provided - see below
//#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include <catch/catch.hpp>

#include <gmock/gmock.h>

#include "googlemock_catch_listener.h"

int main(int argc, char** argv) {
	::testing::InitGoogleTest(&argc, argv);

	::testing::TestEventListeners& listeners = ::testing::UnitTest::GetInstance()->listeners();
	listeners.Append(new GooglemockCatchListener());
	delete listeners.Release(listeners.default_result_printer());

	return Catch::Session().run(argc, argv);
}