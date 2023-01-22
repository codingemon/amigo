<%@page import="com.lec.amigo.vo.UserVO"%>
<%@page import="com.lec.amigo.vo.ChatRoom"%>
<%@page import="org.springframework.web.servlet.tags.Param"%>
<%@page import="com.lec.amigo.vo.ChatVO"%>
<%@page import="java.util.List"%>
<%@page import="com.lec.amigo.dao.ChatDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
   
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>

<% 
	UserVO user = (UserVO)session.getAttribute("user");
	int index=Integer.parseInt(request.getParameter("index"));
	int user_no = user.getUser_no(); 
	
/*
	if((int)request.getAttribute("idCheck")>0){
		index = (int)request.getAttribute("idCheck");
	     System.out.println(index+"로그인성공!");
	     
	}else{
		System.out.println(index+"로그인실패!");
	}
*/

	ChatDAO dao = new ChatDAO();
	List<ChatVO> chatList = dao.getChatList(index);
	
	
%>


	



<meta charset="UTF-8">
<title>Insert title here</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
  <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.1/dist/jquery.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.1/jquery.min.js"></script>
  <style>
  	.container {
	width: 500px;
	}
	
	#list {
	height: 300px;
	padding: 15px;
	overflow: auto;
	}
  </style>
	<script>

    $(document).ready(function () {
    	/*
		$('#chat_no_'+${chat.getChat_no() }).click(function(){
			console.log('하이하이');
			$('.chat_option_item').toggle();

		});
    	*/
    });
    
    

    

	</script>
</head>
<body>

	<c:set var="user" value="<%=user %>"/>
	<div class="container">
		<h1 class="page-header">채팅방</h1>		
	
		<table class="table table-bordered" style="background: #81DAF5;">
		
		<!-- 
		<tr>
			<td><input type="text" name="user" id="user" class="form-control" placeholder="유저명" required="required"></td>
			<td>
				<button type="button" class="btn btn-default" id="btnConnect">연결</button>
				<button type="button" class="btn btn-default" id="btnDisconnect" disabled>종료</button>
			</td>
		</tr>
		 -->
		
		<tr class="table-borderless">
			
				<td colspan="6">
					<ul id="list" style="list-style: none;">
						<c:forEach var="chat" items="<%= chatList%>">
							<c:choose>
							<c:when test="${chat.getUser_nick()!=user.getUser_nick() }">			
							
							<li style="margin-bottom:3px; clear: both;" class="chat_no_${chat.getChat_no() }">
							[${chat.getUser_nick() }] ${chat.getContent()}					 
							<span style="font-size:11px;color:#777;">${chat.getDate() }</span>
							</li>
							</c:when>													
							<c:when test="${chat.getUser_nick()==user.getUser_nick() }">
							
							<li style="margin-bottom:3px; float:right;" class="chat_no_${chat.getChat_no() }">
								<span>${chat.getContent()}</span>
							</li>
							<li class="chat_option_item chat_no_${chat.getChat_no() }">
								<button onclick="chat_delete(${chat.getChat_no()})">삭제</button>
							</li>
							</c:when>
							</c:choose>
							

							
						</c:forEach>		 
					</ul>
				</td>	
		</tr>
		<tr class="table-borderless">
			<td colspan="5"><input type="text" name="msg" id="msg" placeholder="대화 내용을 입력하세요." class="form-control"></td>
			<td colspan="1" style="text-align: rigth;"><button class="btn btn-success" style="width: 100px;" id="chat_submit_btn">보내기</button></td>
		</tr>
		</table>
		
	</div>
	<script>
//채팅 서버 주소
  var url = "ws://localhost:8088/amigo/chatHandler.do";
  let index = "<%=index%>";
  // 웹 소켓
  var ws = new WebSocket(url);
  		function chat_delete(chat_no){
		ws.send('4#' + chat_no+'#'+index);
		$('.chat_no_'+chat_no).remove();
		console.log(chat_no+'넘버확인용');
		}
  	   	// 소켓 이벤트 매핑
  	   	ws.onopen = function () {
  	   		console.log('서버 연결 성공');
  	   	 	let user_name = '<%=user.getUser_nick()%>';
  	   		//print($('#user').val(), '입장했습니다.');
  	   		// 현재 사용자가 입장했다고 서버에게 통지(유저명 전달)
  	   		// -> 1#유저명
  			ws.send('1#' + user_name + '#' + index); 
  			$('#msg').focus();
  			
  			ws.onmessage = function (evt) {	
  			  	console.log(evt.data);
  	  			let msg = evt.data.split("#");
  	  			
  	  			let no;
  	  			let user;
  	  			let txt;
  	  			let roomIndex;
  	  			let chat_no;
  	  			
  	  			if(msg.length==2){
  	  				let delete_no = msg[0];
  	  				
  	  				console.log(delete_no);
  	  				roomIndex = msg[1];
  	  				
  	  				if(parseInt(roomIndex)==index){
  	  					console.log('여기 들어와짐?'+delete_no);
  	  					$('.chat_no_'+delete_no).remove();
	  				}
  	  					
  	  			}else if(msg.length==3){
  	  			    no = msg[0];
  	  			    user = msg[1];
  	  			    roomIndex = msg[2];
  	  			}else if(msg.length==5){
  	  				no = msg[0]; 
  	  				user = msg[1];
  	  				txt = msg[2];
  	  				roomIndex = msg[3];
  	  				chat_no = msg[4];
  	  			}
  	  			
  	  			console.log('인덱스:'+index+'룸인덱스:'+roomIndex);		
  	  			if (no == '1') {
  	  				if(parseInt(roomIndex)==index){
  	  					print2(user);
  	  				}
  	  			} else if (no == '2') {
  	  				if(parseInt(roomIndex)==index){
  	  					
  	  					if(user=='<%=user.getUser_nick()%>'){
  	  				
  	  						printMe(txt, chat_no);
  	  					}else{
  	  						print(user, txt, chat_no);
  	  						
  	  					}
  	  					
  	  				}
  	  			} else if (no == '3') {
  	  				if(parseInt(roomIndex)==index){
  	  					print3(user);
	  				}
  	  				
  	  			}
  	  			$('#list').scrollTop($('#list').prop('scrollHeight'));
  	  		};
  	  	   			
  	  		ws.onclose = function (evt) {
  	  			console.log(evt.data);
  	  			console.log('소켓이 닫힙니다.');
  	  			
  	  			//setTimeout(function(){connect();}, 1000);
  	  			
  	  		};

  	  		ws.onerror = function (evt) {
  	  			console.log(evt.data);
  	  		};
  	  	  // 메세지 전송 및 아이디
  	  	  function print(user, txt, chat_no) {
  	  	  	let temp = '';
  	  	
  	  	  	temp += '<li style="margin-bottom:3px; clear: both;" class="chat_no_'+chat_no+'">';
  	  	  	temp += '[' + user + '] ';
  	  	  	temp += txt;
  	  	  	temp += ' <span style="font-size:11px;color:#777;">' + new Date().toLocaleTimeString() + '</span>';
  	  	  	temp += '</li>';
  	  	  			
  	  	  	$('#list').append(temp);
  	  	  	$('#list').scrollTop($('#list').prop('scrollHeight'));
  	  	  }
  	  	  function printMe(txt, chat_no) {
  	  		  	
  	  		  	console.log('확인용숫자'+chat_no);
    	  	  	let temp = '';
    	  	  	temp += '<li style="margin-bottom:3px; float:right;" class="chat_no_'+chat_no+'">';
    	  	  	temp += '<span>'+txt+'</span>';
    	  	  	temp += '</li>';
    	  	  	temp += '<li class="chat_option_item chat_no_'+chat_no+'">';
    	  	  	temp += '<button onclick="chat_delete('+chat_no+')">삭제</button>';
    	  	  	temp += '</li>';
    	  	  
    	  	  			
    	  	  	$('#list').append(temp);
    	  	  	$('#list').scrollTop($('#list').prop('scrollHeight'));
    	  }
  	  	  		
  	  	  // 다른 client 접속		
  	  	  function print2(user) {
  	  	  	let temp = '';
  	  	  	temp += '<li style="margin-bottom:3px;">';
  	  	  	temp += "'" + user + "' 이(가) 입장했습니다." ;
  	  	  	temp += ' <span style="font-size:11px;color:#777;">' + new Date().toLocaleTimeString() + '</span>';
  	  	  	temp += '</li>';
  	  	  	$('#list').append(temp);
  	  	  }

  	  	  // client 접속 종료
  	  	  function print3(user) {
  	  	  	let temp = '';
  	  	  	temp += '<li style="margin-bottom:3px;">';
  	  	  	temp += "'" + user + "' 이(가) 종료했습니다." ;
  	  	  	temp += ' <span style="font-size:11px;color:#777;">' + new Date().toLocaleTimeString() + '</span>';
  	  	  	temp += '</li>';
  	  	  			
  	  	  	$('#list').append(temp);
  	  	  }
  	  	  $('#chat_submit_btn').click(function(){
	  	  		console.log($(this));
  	  	  		ws.send('2#' + user_name + '#' + $(this).val() + '#'+index); //서버에게
  	  	  		//printMe($('#msg').val()); //본인 대화창에
  	  	        $('#msg').val('');
  	  	  		$('#msg').focus();
  	  	  	}
  	  	  	);
  	  	  
  	  	  $('#msg').keydown(function() {
  	  	  	if (event.keyCode == 13) {	
  	  	  		//서버에게 메시지 전달
  	  	  		//2#유저명#메시지	  		
  	  	  		console.log($(this));
  	  	  		ws.send('2#' + user_name + '#' + $(this).val() + '#'+index); //서버에게
  	  	  		
  	  	  		//printMe($(this).val()); //본인 대화창에
  	  	  		
  	  	        $('#msg').val('');
  	  	  		$('#msg').focus();
  	  	  				
  	  	  	}
  	  	  });
  	  	  
  	    	
  		};
          
  		



  
  </script>

</body>
</html>