import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
 
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/models/chat_user.dart';
import 'package:we_talk/screens/profile_screen.dart';
import 'package:we_talk/widgets/chat_user_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    List<ChatUser>_list =[];
    final List<ChatUser>_searchList=[];  
    bool _isSearching = false; 
     late Size mq;
     @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
      SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
     mq = MediaQuery.of(context).size; 
    return GestureDetector(
      onTap:()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () { 
          if(_isSearching){
            setState(() {
              _isSearching = false;
            });
          }
          else{
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar( 
            leading : Icon(CupertinoIcons.home),
            title :_isSearching?TextField(
              decoration :InputDecoration(
                hintText: 'Search user',
                border:InputBorder.none,
              
              ),
                 autofocus: true,
                  style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                           onChanged: (val) {
                          //search logic
                          _searchList.clear();
        
                          for (var i in _list) {
                            if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                                i.email.toLowerCase().contains(val.toLowerCase())) {
                              _searchList.add(i);
                              setState(() {
                                _searchList;
                              });
                            }
                          }
                        },
                  
            ):const  Text('We Talk'),
            actions: [
              IconButton(onPressed: (){ setState((){
                _isSearching = !_isSearching;
              });}, icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid:CupertinoIcons.search)),
              IconButton(onPressed: (){
                Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProfileScreen(users: APIs.me,)));
              }, icon: const Icon(Icons.more_vert)),
        
            ],
            
        ), 
        // floating button to add new user
        floatingActionButton: Padding(
        
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(onPressed: () async{
            
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
        
          }, child: const Icon(Icons.add_comment_rounded),),
        ),
           body:StreamBuilder(
        
        stream:APIs.getAllUsers(),
         builder:(context,snapshot){
           switch (snapshot.connectionState) {
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            // return const Center(
                            //     child: CircularProgressIndicator());
        
                            //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              
        
            final data =snapshot.data?.docs;
           _list = data ?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
        if(_list.isNotEmpty){
            return  ListView.builder(
              itemCount:_isSearching?_searchList.length: _list.length,
              padding: EdgeInsets.only(top:mq.height*.009),
              physics:BouncingScrollPhysics(),
          itemBuilder:(context,index){
            return ChatUserCard(users: _isSearching ?
            _searchList[index] : _list[index]);
          
         });
           }
           else{
              return  Center(
                child: Text('No user found',style:TextStyle(fontSize:20)),
              );
           }
           }
          
         },
           )
        ),
      ),
    );
  }
}

 