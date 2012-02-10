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
#define TOKENFILE "smugmug.token"

// the twitter client api id, get from smugmug.com

#define CLIENT_ID "GET_YOUR_OWN_ID"

// the twitter client secret, get from smugmug.com, keep secure.
#define CLIENT_SECRET "GET_YOUR_OWN_SECRET"

// the api object
object auth = Social.SmugMug.client(Security.OAuth.Consumer(CLIENT_ID, CLIENT_SECRET));

int main()
{
  call_out(t1, 1);
  return -1;
}

void t1()
{
  // if we've stored the token previously, we load it up and see if it's still valid.
  // this will save us from always having to authorize the client.
  if(file_stat(TOKENFILE))
  {
    array f = Stdio.read_file(TOKENFILE)/",";
    auth->set_token(Security.OAuth.Token(@f));
   }

  // if we don't have a token, or it was invalid, prompt for login via the browser
  // user will then enter the authorization code here and we can proceed.
  while(!auth->verify_auth())
  {
write("not authorized.\n");
    string cred;

    // if the old token didn't work, remove it.
    rm(TOKENFILE);

    // this is an OSX specific method to open the authentication URL in a browser.
    // you should replace this with something appropriate for your OS.
    Process.system("open '" + auth->get_auth_url(Social.SmugMug.client.FULL_ACCESS, Social.SmugMug.client.MODIFY_PERMISSIONS) + "'");

    // not strictly necessary, but helps prevent confusion if the window takes a moment to open.
    sleep(5);

    write("enter authorization code: ");
    cred = Stdio.stdin.gets();

    // authorize us!
    auth->get_access_token(cred);
  }

  // by saving the token, we can try it next time and possibly avoid having to request authorization.
  object token = auth->get_token();
  Stdio.write_file(TOKENFILE, token->key + "," + token->secret);

  // now, let's perform a "secured" operation:
  write("%O\n", auth->get_user("hww3"));
  exit(0);

}
