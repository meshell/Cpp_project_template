#ifndef GOOGLEMOCK_CATCH_LISTENERINTERCEPTOR_H
#define GOOGLEMOCK_CATCH_LISTENERINTERCEPTOR_H

#include <gmock/gmock.h>
#include <catch/catch.hpp>

class GooglemockCatchListener: public ::testing::EmptyTestEventListener 
{
public:
	virtual ~GooglemockCatchListener() {}

	void OnTestPartResult(const ::testing::TestPartResult& gmock_assertion_result) override
	{
		//	printf("%s in %s:%d\n%s\n",
		//			gmock_assertion_result.failed() ? "*** Failure" : "Success",
		//			gmock_assertion_result.file_name(),
		//			gmock_assertion_result.line_number(),
		//			gmock_assertion_result.summary());
		INFO(gmock_assertion_result.summary() << "\n at " << gmock_assertion_result.file_name() << " (line: " << gmock_assertion_result.line_number() << ")");
		REQUIRE_FALSE(gmock_assertion_result.failed()); // inverse logic
	}
};

#endif //GOOGLEMOCK_CATCH_LISTENERINTERCEPTOR_H

