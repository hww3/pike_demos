// this is a demo of poppa's handy Social.Google and Security.OAuth modules.
// (https://github.com/poppa/Pike-Modules)
//
// this may also be useful as a guide for folks attempting OAuth 
// authorization via other web services.
//
// Copyright 2012 Bill Welliver <bill@welliver.org>
// 
// This work is licensed under a Creative Commons Attribution 3.0 
// United States License. For additional information, see
// http://creativecommons.org/licenses/by/3.0/us/

// the file we store the auth token, should be a secure location
#define TOKENFILE "google.token"

// client id and key can be requested from google apis.
#define CLIENT_ID "GET_YOUR_OWN_ID"
#define CLIENT_KEY "GET_YOUR_OWN_KEY"

// the authorization object; note that we're configured to use "desktop" authorization,
// whereby the browser pops up with the authorization dialog, and the user has to paste
// the authorization value back into this application. clunky, but that's the way of OAuth.
object auth = Social.Google.Authorization(CLIENT_ID, CLIENT_KEY, "urn:ietf:wg:oauth:2.0:oob", 0);

int main()
{
  call_out(t1, 1);
  return -1;
}

void t1()
{
    string cred;

  // if we've stored the token previously, we load it up and see if it's still valid.
  // this will save us from always having to authorize the client.
  if(file_stat(TOKENFILE))
  {
    string f = Stdio.read_file(TOKENFILE);
    auth->set_from_cookie(f);
   }

  while(!auth->is_renewable || auth->is_expired())
  {

    // if the old token didn't work, remove it.
    rm(TOKENFILE);

    // this is an OSX specific method to open the authentication URL in a browser.
    // you should replace this with something appropriate for your OS.
    // note that SCOPE is a required value and will vary depending on what you want to do, API-wise.
    //
    // NOTE:
    //
    // were this a web application, rather than an interactive command-line tool, you'd presumably 
    // save the state and record of what the user was doing before redirecting to the auth url. 
    // Once the authorization was complete, the redirect url specified earlier would be called 
    // with the authorization code. The app would use that code to get (and optionally save) 
    // the access token, which should be used in the future to access that service on behalf of 
    // the authorized user.
    Process.system("open '" + auth->get_auth_uri((["scope": Social.Google.Tasks.SCOPE_RO])) + "'");

    // not strictly necessary, but helps prevent confusion if the window takes a moment to open.
    sleep(5);

    write("enter authorization code: ");
    cred = Stdio.stdin.gets();

    // authorize us!
    string token = auth->request_access_token(cred);
    Stdio.write_file(TOKENFILE, token);

  }

  object tasks = Social.Google.Tasks(auth);

  werror("%O\n", tasks->get_lists());

  exit(0);
}
