#include "dummy.h"


namespace CppTemplate {

Dummy::Dummy ():
  hello_string_(""),
  world_string_(""),
  speechless_(true)
{

}

Dummy::Dummy (const std::string& hello_string,
       const std::string& world_string):
  hello_string_(hello_string),
  world_string_(world_string),
  speechless_(false)
{
  speechless_ = hello_string.empty() && world_string.empty();
}

 std::string Dummy::say_hello () const
 {
  std::string hello(hello_string_);
   hello.append(" ");
   hello.append(world_string_);
   return hello;
 }

 bool Dummy::speechless () const
 {
   return speechless_;
 }

} // namespace CppTemplate
