package org.bigbluebutton.air.users.views.participants {
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	
	import spark.events.IndexChangeEvent;
	
	import org.bigbluebutton.air.common.PageEnum;
	import org.bigbluebutton.air.common.TransitionAnimationEnum;
	import org.bigbluebutton.air.main.models.IUserUISession;
	import org.bigbluebutton.lib.chat.models.IChatMessagesSession;
	import org.bigbluebutton.lib.chat.models.PrivateChatMessage;
	import org.bigbluebutton.lib.main.models.IUserSession;
	import org.bigbluebutton.lib.user.models.User;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	public class ParticipantsViewMediator extends Mediator {
		
		[Inject]
		public var view:IParticipantsView;
		
		[Inject]
		public var userSession:IUserSession
		
		[Inject]
		public var userUISession:IUserUISession
		
		[Inject]
		public var chatMessagesSession:IChatMessagesSession;
		
		protected var dataProviderConversations:ArrayCollection;
		
		protected var dataProvider:ArrayCollection;
		
		private var _usersAdded:Array = new Array();
		
		override public function initialize():void {
			dataProvider = userSession.userList.users;
			view.list.dataProvider = dataProvider;
			view.list.addEventListener(IndexChangeEvent.CHANGE, onSelectParticipant);
			userSession.userList.userChangeSignal.add(userChanged);
			view.conversationsList.addEventListener(IndexChangeEvent.CHANGE, onSelectChat);
			initializeDataProviderConversations();
		}
		
		protected function onSelectChat(event:IndexChangeEvent):void {
			var item:Object = dataProviderConversations.getItemAt(event.newIndex);
			if (item) {
				if (item.hasOwnProperty("button")) {
					userUISession.pushPage(PageEnum.SELECT_PARTICIPANT, item, TransitionAnimationEnum.SLIDE_LEFT)
				} else {
					userUISession.pushPage(PageEnum.CHAT, item, TransitionAnimationEnum.SLIDE_LEFT)
				}
			} else {
				throw new Error("item null on ChatRoomsViewMediator");
			}
		}
		
		private function initializeDataProviderConversations():void {
			dataProviderConversations = new ArrayCollection();
			dataProviderConversations.addItem({name: ResourceManager.getInstance().getString('resources', 'chat.item.publicChat'), publicChat: true, user: null, chatMessages: chatMessagesSession.publicChat});
			for each (var chatObject:PrivateChatMessage in chatMessagesSession.privateChats) {
				chatObject.userOnline = userSession.userList.hasUser(chatObject.userID);
				chatObject.privateChat.chatMessageChangeSignal.add(populateList);
				if (chatObject.privateChat.messages.length > 0) {
					addChat({name: chatObject.userName, publicChat: false, user: userSession.userList.getUser(chatObject.userID), chatMessages: chatObject.privateChat, userID: chatObject.userID, online: chatObject.userOnline});
				}
			}
			view.conversationsList.dataProvider = dataProviderConversations;
		}
		
		public function populateList(UserID:String):void {
			var newUser:User = userSession.userList.getUserByUserId(UserID);
			if ((newUser != null) && (!isExist(newUser, dataProviderConversations)) && (!newUser.me)) {
				var pcm:PrivateChatMessage = chatMessagesSession.getPrivateMessages(newUser.userID, newUser.name);
				addChat({name: pcm.userName, publicChat: false, user: newUser, chatMessages: pcm.privateChat, userID: pcm.userID, online: true}, dataProvider.length - 1);
			}
			dataProviderConversations.refresh();
		}
		
		/**
		 * If user wasn't already added, adding to the data provider
		 **/
		private function addChat(chat:Object, pos:Number = NaN):void {
			if (!userAlreadyAdded(chat.userID)) {
				_usersAdded.push(chat.userID);
				if (isNaN(pos)) {
					dataProviderConversations.addItem(chat);
				} else {
					dataProviderConversations.addItemAt(chat, pos);
				}
			}
			dataProviderConversations.refresh();
		}
		
		/**
		 * Check if User was already added to the data provider
		 **/
		private function userAlreadyAdded(userID:String):Boolean {
			for each (var str:String in _usersAdded) {
				if (userID == str) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Check if User is already added to the dataProvider
		 *
		 * @param User
		 */
		private function isExist(user:User, dp:ArrayCollection):Boolean {
			for (var i:int = 0; i < dp.length; i++) {
				if (dp.getItemAt(i).userID == user.userID) {
					return true;
				}
			}
			return false;
		}
		
		private function userChanged(user:User, property:String = null):void {
			dataProvider.refresh();
		}
		
		protected function onSelectParticipant(event:IndexChangeEvent):void {
			if (event.newIndex >= 0) {
				var user:User = dataProvider.getItemAt(event.newIndex) as User;
				userUISession.pushPage(PageEnum.USER_DETAILS, user, TransitionAnimationEnum.SLIDE_LEFT);
			}
		}
		
		override public function destroy():void {
			view.list.removeEventListener(IndexChangeEvent.CHANGE, onSelectParticipant);
			view.conversationsList.removeEventListener(IndexChangeEvent.CHANGE, onSelectChat);
			
			for each (var chatObject:PrivateChatMessage in chatMessagesSession.privateChats) {
				chatObject.privateChat.chatMessageChangeSignal.remove(populateList);
			}
			
			userSession.userList.userChangeSignal.remove(userChanged);
			super.destroy();
			view.dispose();
			view = null;
		}
	}
}
