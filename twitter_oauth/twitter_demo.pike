// This is a demo of the Social.Twitter module written by poppa.
// https://github.com/poppa/Pike-Modules
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
#define TOKENFILE "twitter.token"

// the twitter client api id, get from dev.twitter.com

#define CLIENT_ID "GET_YOUR_OWN_ID"

// the twitter client secret, get from dev.twitter.com, keep secure.
#define CLIENT_KEY "GET_YOUR_OWN_SECRET"

// the api object
object twitter = Social.Twitter.Api(Security.OAuth.Consumer(CLIENT_ID, CLIENT_KEY));

int main()
{
  call_out(t1, 1);
  return -1;
}

void t1()
{
  object user;

  // if we've stored the token previously, we load it up and see if it's still valid.
  // this will save us from always having to authorize the client.
  if(file_stat(TOKENFILE))
  {
    array f = Stdio.read_file(TOKENFILE)/",";
    twitter->set_token(Security.OAuth.Token(@f));
   }

  // if we don't have a token, or it was invalid, prompt for login via the browser
  // user will then enter the authorization code here and we can proceed.
  while(!(user = twitter->verify_credentials()))
  {
    string cred;

    // if the old token didn't work, remove it.
    rm(TOKENFILE);

    // this is an OSX specific method to open the authentication URL in a browser.
    // you should replace this with something appropriate for your OS.
    Process.system("open " + twitter->get_auth_url());

    // not strictly necessary, but helps prevent confusion if the window takes a moment to open.
    sleep(5);

    write("enter authorization code: ");
    cred = Stdio.stdin.gets();

    // authorize us!
    twitter->get_access_token(cred);
  }

  // by saving the token, we can try it next time and possibly avoid having to request authorization.
  object token = twitter->get_token();
  Stdio.write_file(TOKENFILE, token->key + "," + token->secret);

  werror("user: %O\n", user);

  // now, let's perform a "secured" operation:
  foreach(twitter->get_home_timeline();;object message)
  {
    write("at %s, %s tweeted: %s\n", message->created_at->nice_print(),  message->user->name, message->text);
  }
  exit(0);
}
