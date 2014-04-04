//Provides: unix_gethostname
//Requires: caml_new_string
function unix_gethostname() {
  return caml_new_string('localhost');
}
