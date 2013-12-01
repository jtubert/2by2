exports.main = function(request, response){
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  var user = request.params.user;
  var items = [];
  var followers = [];

  var twoByTwoUsers = [];

  var userQuery = new Parse.Query(Parse.User);
  userQuery.each(function(u) {
    var obj = {username:u.get("fullName"),id:u.id};
    twoByTwoUsers.push(obj);
  });

  var followQuery = new Parse.Query("Followers");
  followQuery.equalTo("userID", user);
  followQuery.each(function(f) {
    followers.push(f.get("followingUserID"));
  });

    //   
  
  query.get(user, {
    success: function(user) {
      var email = user.get("email");
      var username = user.get("username");
      Parse.Cloud.httpRequest({
        url:'https://graph.facebook.com/me/friends?access_token='+user.get('authData').facebook.access_token,
        success:function(httpResponse){
          var followersStr = followers.join();
          //console.log(user.get('authData').facebook.access_token);
          //response.success("getFacebookFriends: "+httpResponse.data.data.length);
          var friends = httpResponse.data.data;

          for (var i = friends.length - 1; i >= 0; i--) {
            var n1 = friends[i].name;
            for (var j = twoByTwoUsers.length - 1; j >= 0; j--) {
              var n2 = twoByTwoUsers[j].username;
              if(n1 == n2){
                var following = false;
                if(followersStr.indexOf(twoByTwoUsers[j].id) != -1){
                  following = true;
                }

                var obj ={name:friends[i].name,parseID:twoByTwoUsers[j].id,facebookID:friends[i].id,following:following};
                items.push(obj);
              }
            };
            
          };  

          response.success(items); 
        },
        error:function(httpResponse){
          response.error(httpResponse);
        }
      });
               
    },
    error: function(error) {
        //console.error("Got an error " + error.message);
        response.error(error);
    }
  });
}