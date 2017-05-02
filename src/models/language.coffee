_reduce = require 'lodash/reduce'
_defaultsDeep = require 'lodash/defaultsDeep'

config = require '../config'

# missing: card_info, channel picker, edit group, edit group change badge
# events 'participants', 'begins', 'ends'
# group list 'members'
# thread points
# friendspage
# profile page share


# coffeelint: disable=max_line_length
strings =
  'general.loading': {
    en: 'Loading...',
    es: 'Cargando...'
  },
  'general.cancel': {
    en: 'Cancel'
    es: 'Cancelar'
  },
  'general.save': {
    en: 'Save',
    es: 'Guardar'
  },
  'general.create': {
    en: 'Create',
    es: 'Crear'
  },
  'general.discard': {
    en: 'Discard',
    es: 'Descartar'
  },
  'general.done': {
    en: 'Done',
    es: 'Hecho'
  },
  'general.info': {
    en: 'Info',
    es: 'Información'
  },
  'general.history': {
    en: 'History',
    es: 'Historia'
  },
  'general.graphs': {
    en: 'Graphs',
    es: 'Gráficos'
  },
  'general.members': {
    en: 'Members',
    es: 'Miembros'
  },
  'general.guides': {
    en: 'Guides',
    es: 'Guías'
  },
  'general.popular': {
    en: 'Popular',
    es: 'Popular'
  },
  'general.decks': {
    en: 'Decks',
    es: 'Barajas'
  },
  'general.chat': {
    en: 'Chat',
    es: 'Conversacion'
  },
  'general.inbox': {
    en: 'Inbox',
    es: 'Bandeja de entrada'
  },
  'general.clan': {
    en: 'Clan',
    es: 'Clan'
  },
  'general.profile': {
    en: 'Profile',
    es: 'Perfil'
  },
  'general.username': {
    en: 'Username',
    es: 'Nombre de usuario'
  },
  'general.email': {
    en: 'Email',
    es: 'Correo electrónico'
  },
  'general.password': {
    en: 'Password',
    es: 'Contraseña'
  },
  'general.general': {
    en: 'General',
    es: 'General'
  },
  'general.notifications': {
    en: 'Notifications',
    es: 'Notificaciones'
  },
  'general.description': {
    en: 'Description',
    es: 'Descripción'
  },
  'general.signIn': {
    en: 'Sign in',
    es: 'Iniciar sesión'
  },
  'general.signUp': {
    en: 'Sign up',
    es: 'Registrarse'
  },
  'general.yes': {
    en: 'Yes',
    es: 'Sí'
  },
  'addDeck.nameHintText': {
    en: 'Enter a name...',
    es: 'Introduce un nombre...'
  },
  'addToHomeSheet.submitButton': {
    en: 'Add to home',
    es: 'Agregar al pantalla principal'
  },
  'arenaPickerDialog.title': {
    en: 'Max Arena',
    es: 'Máxima Arena'
  },
  'cardPickerDialog.title': {
    en: 'Insert card',
    es: 'Insertar carta'
  },
  'claimClanDialog.title': {
    en: 'Claim clan',
    es: 'Reclamar clan'
  },
  'claimClanDialog.groupNameHintText': {
    en: 'Group name',
    es: 'Nombre de grupo'
  },
  'claimClanDialog.text1': {
    en: 'Add this code to your clan description in the game to verify your ownership',
    es: 'Agrega este código a la descripción de tu clan para verificar tu propiedad'
  },
  'claimClanDialog.text2': {
    en: 'Claiming ownership will unlock',
    es: 'Reclamar la propiedad desbloqueará'
  },
  'claimClanDialog.text3': {
    en: 'Private clan chat',
    es: 'Chat privado del clan'
  },
  'claimClanDialog.submitButton': {
    en: 'Claim',
    es: 'Reclamar'
  },
  'clanGraphs.empty': {
    en: 'Clan graphs coming soon. We need to collect more than 1 week of data',
    es: 'Los gráficos del clan vendrán pronto. Necesitamos recolectar más de una semana de datos'
  },
  'clanInfo.type': {
    en: 'Type',
    es: 'TIpo'
  },
  'clanInfo.minTrophies': {
    en: 'Required trophies',
    es: 'Trofeos requeridos'
  },
  'clanInfo.region': {
    en: 'Location',
    es: 'Ubicación'
  },
  'clanInfo.lastUpdatedTime': {
    en: 'Last updated',
    es: 'Última vez que actualizó'
  },
  'clanInfo.claimClan': {
    en: 'Claim clan',
    es: 'Reclamar clan'
  },
  'clanInfo.clanChat': {
    en: 'Clan chat',
    es: 'Chat del clan'
  },
  'clanInfo.verifySelf': {
    en: 'Verify self',
    es: 'Verificarme'
  },
  'compose.titleHintText': {
    en: 'Title...',
    es: 'Título...'
  },
  'compose.responseHintText': {
    en: 'Write a response...',
    es: 'Escribe una respuesta...'
  },
  'compose.postHintText': {
    en: 'Write a post...',
    es: 'Escribe una publicación...'
  },
  'conversationImageView.title': {
    en: 'Image',
    es: 'Imagen'
  },
  'conversationInputGifs.hintText': {
    en: 'Search gifs...',
    es: 'Buscar gifs...'
  },
  'conversationInputTextarea.hintText': {
    en: 'Type a message...',
    es: 'Escribe un mensaje...'
  },
  'conversations.me': {
    en: 'Me: ',
    es: 'Yo: '
  },
  'deckList.noDecks': {
    en: 'No decks found',
    es: 'No se han encontrado barajas'
  },
  'deckList.noDecksMine': {
    en: 'Select a popular deck to add it, or create a new deck',
    es: 'Selecciona una baraja popular para agregarla, o crear una nueva baraja'
  },
  'deckInfo.personalStats': {
    en: 'Personal stats',
    es: 'Estadísticas personales'
  },
  'deckInfo.personalStats': {
    en: 'Community stats',
    es: 'Estadísticas de la comunidad'
  },
  'deckInfo.winPercentage': {
    en: 'Win percentage',
    es: 'Porcentaje de victoria'
  },
  'deckInfo.winLossDraw': {
    en: 'W / D / L',
    es: 'V / P / E'
  },
  'decksGuides.noGuides': {
    en: 'No guides found',
    es: 'No se han encontrado guías'
  },
  'drawer.menuItemProfile': {
    en: 'Profile',
    es: 'Perfil'
  },
  'drawer.menuItemClan': {
    en: 'Clan',
    es: 'Clan'
  },
  'drawer.menuItemDecks': {
    en: 'Decks',
    es: 'Baraja'
  },
  'drawer.menuItemCommunity': {
    en: 'Community',
    es: 'Comunidad'
  },
  'drawer.menuItemConversations': {
    en: 'Conversations',
    es: 'Conversaciones'
  },
  'drawer.menuItemPlayers': {
    en: 'Players',
    es: 'Jugadores'
  },
  'drawer.menuItemNeedsApp': {
    en: 'Get the app',
    es: 'Consigue la aplicación'
  },
  'editEvent.nameHintText': {
    en: 'Event name',
    es: 'Nombre del evento'
  },
  'editEvent.tournamentIdHintText': {
    en: 'ID tag #',
    es: '#tag de identificación'
  },
  'editEvent.passwordLabel': {
    en: 'Password protected',
    es: 'Protegido con contraseña'
  },
  'editEvent.dateHintText': {
    en: 'Date',
    es: 'Fecha'
  },
  'editEvent.startTimeHintText': {
    en: 'Start time',
    es: 'Tiempo de inicio'
  },
  'editEvent.durationHintText': {
    en: 'Duration',
    es: 'Duración'
  },
  'editEvent.minTrophiesHintText': {
    en: 'Min trophies',
    es: 'Trofeos mínimos'
  },
  'editEvent.maxTrophiesHintText': {
    en: 'Max trophies',
    es: 'Trofeos máximos'
  },
  'editEvent.maxUserCountHintText': {
    en: 'Event size',
    es: 'Tamaño del evento'
  },
  'editGroup.nameHintText': {
    en: 'Group name',
    es: 'Nombre del grupo'
  },
  'editGroupChangeBadge.appBarTitle': {
    en: 'Group badge',
    es: 'Emblema de grupo'
  },
  'editGroupChangeBadge.headerTitle': {
    en: 'Badge',
    es: 'Emblema'
  },
  'editGuide.titleHintText': {
    en: 'Deck name',
    es: 'Nombre de la baraja'
  },
  'editGuide.videoUrlHintText': {
    en: 'YouTube URL (optional)',
    es: 'Enlace de YouTube (opcional)'
  },
  'editGuide.summaryHintText': {
    en: 'Brief summary',
    es: 'Breve resumen'
  },
  'editGuide.markdownEditorHintText': {
    en: 'Full guide writeup...',
    es: 'Desarrollo completo de la guía'
  },
  'editProfile.playerTagInputHintText': {
    en: 'Player tag',
    es: 'Tag del jugador'
  },
  'editProfile.avatarButtonText': {
    en: 'Upload photo',
    es: 'Subir una foto'
  },
  'editProfile.forumSigButtonText': {
    en: 'Create forum signature',
    es: 'Crear firma de foro'
  },
  'editProfile.logoutButtonText': {
    en: 'Logout',
    es: 'Cerrar sesión'
  },
  'event.joinButtonText': {
    en: 'Join event',
    es: 'Unirse al evento'
  },
  'eventInfo.tournamentIdHintText': {
    en: 'ID tag',
    es: 'Tag de identificación'
  },
  'events.noEvents': {
    en: 'There are currently no public events scheduled. Check back soon!',
    es: 'No hay eventos públicos programados actualmente. Vuelve a probar en un rato'
  },
  'events.noEventsMine': {
    en: 'You haven\'t joined any events',
    es: 'No te has unido a ningún evento'
  },
  'findFriends.searchPlaceholder': {
    en: 'Search by username',
    es: 'Buscar por nombre de usuario'
  },
  'forumSignature.subheadColors': {
    en: 'Background color',
    es: 'Color de fondo'
  },
  'forumSignature.subheadFavoriteCard': {
    en: 'Favorite card',
    es: 'Carta favorita'
  },
  'forumSignature.label': {
    en: 'Signature URL',
    es: 'Enlace de firma'
  },
  'forumSignature.help': {
    en: 'Where do I paste this?',
    es: 'Dónde pego esto?'
  },
  'friends.usersOnline': {
    en: 'Online',
    es: 'En línea'
  },
  'friends.usersAll': {
    en: 'All',
    es: 'Todos'
  },
  'getAppDialog.text': {
    en: 'Take your stats on the go with the Starfire app for Android and iOS!',
    es: 'Mira tus estadísticas cuando quieras con la app de Starfire para Android e iOS!'
  },
  'groupAnnouncements.groupAnnouncements': {
    en: 'Announcements coming soon...',
    es: 'Pronto habrá novedades'
  },
  'groupEditChannel.nameInputHintText': {
    en: 'Channel name',
    es: 'Nombre del canal'
  },
  'groupInfo.joinButtonText': {
    en: 'Join group',
    es: 'Unirse al grupo'
  },
  'groupInfo.title': {
    en: 'About',
    es: 'Acerca de'
  },
  'groupInvite.headsUpNotificationTitle': {
    en: 'User invited!',
    es: 'Usuario invitado!'
  },
  'groupInvite.headsUpNotificationDetails': {
    en: 'They have been notified',
    es: 'Han sido notificados'
  },
  'groupList.empty': {
    en: 'No groups found',
    es: 'No se han encontrado grupos'
  },
  'groupSettings.leaveGroup': {
    en: 'Leave group',
    es: 'Salir del grupo'
  },
  'groupSettings.chatMessage': {
    en: 'New chat messages',
    es: 'Mensajes nuevos'
  },
  'groups.myGroupList': {
    en: 'My groups',
    es: 'Mis grupos'
  },
  'groups.openGroupList': {
    en: 'Open groups',
    es: 'Grupos abiertos'
  },
  'installOverlay.title': {
    en: 'Add Starfire to homescreen',
    es: 'Agregar Starfire a la pantalla principal'
  },
  'installOverlay.text': {
    en: 'Tap',
    es: 'Toque'
  },
  'installOverlay.instructions': {
    en: 'Select \'Add to homescreen\' to pin the Starfi.re web app',
    es: 'Selecciona \'Añadir a la pantalla principal\' para guardar la aplicación web de Starfi.re'
  },
  'installOverlay.closeButtonText': {
    en: 'Got it',
    es: 'Entendido'
  },
  'join.title': {
    en: 'Get started!',
    es: 'Empecemos!'
  },
  'join.createAccountButtonText': {
    en: 'Create account',
    es: 'Crear cuenta'
  },
  'joinGroupDialog.error': {
    en: 'Incorrect password',
    es: 'Contraseña incorrecta'
  },
  'joinGroupDialog.text': {
    en: 'Ask your clan leader for the group password to join',
    es: 'Pide al líder de tu clan la contraseña del grupo para unirte'
  },
  'offlineOverlay.text': {
    en: 'Looks like you\'re offline. Reconnect to the internet to resume',
    es: 'Parece que estás sin conexión. Reconectate a Internet para continuar'
  },
  'offlineOverlay.closeButtonText': {
    en: 'Close this message',
    es: 'Cerrar este mensaje'
  },
  'playersFollowing.emptyDiv1': {
    en: 'Keep track of your friends or favorite players!',
    es: 'Sigue la pista de tus amigos o tus jugadores favoritos!'
  },
  'playersFollowing.emptyDiv2': {
    en: 'Find players to follow through chat or the players list',
    es: 'Encuentra jugadores para seguirlos a través del chat o la lista de jugadores'
  },
  'playersSearch.playerTagError': {
    en: 'Hmm, we can\'t find that tag',
    es: 'Hmm, no podemos encontrar esa etiqueta'
  },
  'playersSearch.description': {
    en: 'Find any player\'s stats, then follow them to stay up to date',
    es: 'Encuentra cualquiera estadisticas De jugador, entonces siguelos para mantenerte al tanto de todo'
  },
  'playersSearch.playerTagInputHintText': {
    en: 'Plager ID tag #',
    es: 'Tag de identificación'
  },
  'playersSearch.trackButtonText': {
    en: 'Find player',
    es: 'Encontrar jugadores'
  },
  'playersSearch.dialogDescription': {
    en: 'Searching...',
    es: 'Buscando...'
  },
  'policies.title': {
    en: 'Privacy and content',
    es: 'Privacidad y contenido'
  },
  'policies.description': {
    en: 'By registering, you agree to Starfire\'s Privacy Policy, Terms of Service, and Supercell\'s Fan Content Policy',
    es: 'Al registrarse, acepta la Política de privacidad de Starfire, los Términos de servicio y la Política de contenido de fans de Supercell'
  },
  'profileChests.chestsTitle': {
    en: 'Upcoming chests',
    es: 'Próximos cofres'
  },
  'profileChests.chestsUntilTitle': {
    en: 'Chests until',
    es: 'Cofres hasta'
  },
  'profileDialog.message': {
    en: 'Message',
    es: 'Mensaje'
  },
  'profileDialog.block': {
    en: 'Block',
    es: 'bloquear'
  },
  'profileDialog.unblock': {
    en: 'Unblock',
    es: 'Desbloquear'
  },
  'profileDialog.flag': {
    en: 'Report',
    es: 'Reportar'
  },
  'profileDialog.isFlagged': {
    en: 'Reported',
    es: 'Reportado'
  },
  'profileDialog.ban': {
    en: 'Ban',
    es: 'Ban'
  },
  'profileDialog.chatBanned': {
    en: 'Banned',
    es: 'Eliminado'
  },
  'profileDialog.delete': {
    en: 'Delete',
    es: 'Borrar'
  },
  'profileHistory.currentTitle': {
    en: 'Current deck',
    es: 'Baraja actual'
  },
  'profileHistory.otherDecksTitle': {
    en: 'Other decks',
    es: 'Otras barajas'
  },
  'profileHistory.otherDecksEmpty': {
    en: 'No other decks found',
    es: 'Ninguna otra baraja encontrada'
  },
  'profileInfo.statWins': {
    en: 'Wins',
    es: 'Victorias'
  },
  'profileInfo.statLosses': {
    en: 'Losses',
    es: 'Derrotas'
  },
  'profileInfo.statDraws': {
    en: 'Draws',
    es: 'Empates'
  },
  'profileInfo.statWinRate': {
    en: 'Win rate',
    es: 'Porcentaje de victorias'
  },
  'profileInfo.statCrownsEarned': {
    en: 'Crowns earned',
    es: 'Coronas ganadas'
  },
  'profileInfo.statCrownsLost': {
    en: 'Crowns lost',
    es: 'Coronas perdidas'
  },
  'profileInfo.statCurrentWinStreak': {
    en: 'Current win streak',
    es: 'Actual racha de victorias'
  },
  'profileInfo.statCurrentLossStreak': {
    en: 'Current loss streak',
    es: 'Actual racha de derrotas'
  },
  'profileInfo.statMaxWinStreak': {
    en: 'Max win streak',
    es: 'Máxima racha de victorias'
  },
  'profileInfo.statMaxLossStreak': {
    en: 'Max loss streak',
    es: 'Máxima racha de derrotas'
  },
  'profileInfo.statFavoriteCard': {
    en: 'Current favorite card',
    es: 'Actual carta favorita'
  },
  'profileInfo.statThreeCrowns': {
    en: 'Three crown wins',
    es: 'Victorias de tres coronas'
  },
  'profileInfo.statCardsFound': {
    en: 'Cards found',
    es: 'Cartas encontradas'
  },
  'profileInfo.statMaxTrophies': {
    en: 'Highest trophies',
    es: 'Mayor cantidad de trofeos'
  },
  'profileInfo.statTotalDonations': {
    en: 'Total donations',
    es: 'Donaciones totales'
  },
  'profileInfo.lastUpdatedTime': {
    en: 'Last updated',
    es: 'última vez que actualizó'
  },
  'profileInfo.followButtonText': {
    en: 'Follow',
    es: 'Seguir'
  },
  'profileInfo.followButtonIsFollowingText': {
    en: 'Unfollow',
    es: 'Dejar de seguir'
  },
  'profileInfo.moreDetailsButtonText': {
    en: 'More details',
    es: 'Más detalles'
  },
  'profileInfo.splitsInfoCardText': {
    en: 'Note: the stats below will only account for your previous 25 games initially. All future stats will be tracked',
    es: 'Nota: estas estadísticas inicialmente solo tienen en cuenta tus últimas 25 partidas. Todas las estadísticas se guardarán a partir de ahora'
  },
  'profileInfo.subheadStats': {
    en: 'Stats',
    es: 'Estadísticas'
  },
  'profileInfo.subheadLadder': {
    en: 'Ladder',
    es: 'Partidas por trofeos'
  },
  'profileInfo.subheadGrandChallenge': {
    en: 'Grand challenge',
    es: 'Gran desafío'
  },
  'profileInfo.subheadClassicChallenge': {
    en: 'Classic challenge',
    es: 'Desafío clásico'
  },
  'profileGraphs.trophies': {
    en: 'Trophies',
    es: 'Trofeos'
  },
  'profileLanding.description': {
    en: 'Enter your player ID tag to start automatically tracking your wins, losses, donations, and more',
    es: 'Introduce tu tag de identificación para recopilar automáticamente tus victorias, derrotas, donaciones y más'
  },
  'profileLanding.trackButtonText': {
    en: 'Track my stats',
    es: 'Encuentra mis estadísticas'
  },
  'profileLanding.terms': {
    en: 'You can find your player tag by tapping on your username in Clash Royale to open your profile. It\'s located right below your username',
    es: 'Puedes encontrar tu etiqueta de jugador pulsando en tu nombre de usuario en Clash Royale para abrir tu perfil. Esta ubicado justo debajo de tu nombre de usuario'
  },
  'profileLanding.terms2': {
    en: 'This content is not affiliated with, endorsed, sponsored, or specifically approved by Supercell and Supercell is not responsible for it.',
    es: 'Este contenido no está afiliado, respaldado, patrocinado o aprobado específicamente por Supercell y Supercell no es responsable de ello.'
  },
  'profileLanding.dialogDescription': {
    en: 'Collecting your stats...',
    es: 'Recolectando tus estadísticas...'
  },
  'pushNotificationsSheet.message': {
    en: 'Turn on notifications so you don\'t miss any events or messages',
    es: 'Activa las notificaciones para que así no te pierdas de ningún evento o mensaje'
  },
  'pushNotificationsSheet.submitButtonText': {
    en: 'Turn on',
    es: 'Activar'
  },
  'requestNotificationsCard.request': {
    en: 'Would you like to turn on notifications? You\'ll receive a daily recap of your progress',
    es: 'Te gustaría activar las notificaciones? recibirás diariamente reportes de tu progreso'
  },
  'requestNotificationsCard.turnedOn': {
    en: 'Notifications have been eneabled! You can always adjust them from the settings',
    es: 'Se han activado las notificaciones. Puedes modificarlas en Ajustes'
  },
  'requestNotificationsCard.noThanks': {
    en: 'If you change your mind, notifications can be toggled on from the settings',
    es: 'Si cambias de opinión, puedes cambiar los ajustes de notificación en Ajustes'
  },
  'requestNotificationsCard.cancelText': {
    en: 'No thanks',
    es: 'No, gracias'
  },
  'requestNotificationsCard.submit': {
    en: 'Yes, turn on',
    es: 'Sí, activar'
  },
  'searchInput.placeholder': {
    en: 'Search...',
    es: 'Buscar...'
  },
  'sheet.closeButtonText': {
    en: 'Not now',
    es: 'Ahora no'
  },
  'signIn.title': {
    en: 'Welcome back!',
    es: 'Bienvenido de nuevo!'
  },
  'stepBar.next': {
    en: 'Next',
    es: 'Siguiente'
  },
  'stepBar.back': {
    en: 'Back',
    es: 'Volver'
  },
  'thread.noComments': {
    en: 'No comments found',
    es: 'No se han encontrado comentarios'
  },
  'thread.score': {
    en: 'comments',
    es: 'comentarios'
  },
  'videos.title': {
    en: 'Popular videos',
    es: 'Vídeos populares'
  },
  '404Page': {
    en: 'Page not found',
    es: 'Página no encontrada'
  },
  'addDeckPage.title': {
    en: 'New deck',
    es: 'Nueva baraja'
  },
  'addEventPage.title': {
    en: 'Add event',
    es: 'Añadir evento'
  },
  'addGuidePage.title': {
    en: 'Add guide',
    es: 'Añadir guía'
  },
  'cardsPage.title': {
    en: 'Battle cards',
    es: 'Cartas de batalla'
  },
  'clanPage.empty': {
    en: 'Looks like you\'re not in a clan',
    es: 'Parece que no estás en ningún clan'
  },
  'communityPage.menuText': {
    en: 'Groups',
    es: 'Grupos'
  },
  'decksPage.installMessage': {
    en: 'Add Starfire to your homescreen to quickly access these guides anytime',
    es: 'Añade Starfire a la pantalla principal para acceder a estas guías rápidamente y en cualquier momento'
  },
  'editEventPage.title': {
    en: 'Edit event',
    es: 'Editar evento'
  },
  'editGroupPage.title': {
    en: 'Edit group',
    es: 'Editar grupo'
  },
  'editGuidePage.title': {
    en: 'Edit guide',
    es: 'Editar guía'
  },
  'editProfilePage.title': {
    en: 'Edit profile',
    es: 'Editar perfil'
  },
  'eventPage.title': {
    en: 'Event',
    es: 'Evento'
  },
  'eventPage.shareText': {
    en: 'Come join my tournament',
    es: 'Únete a mi torneo'
  },
  'eventPage.leave': {
    en: 'Are you sure you want to leave?',
    es: 'Seguro que quieres salir?'
  },
  'eventsPage.title': {
    en: 'Events',
    es: 'Eventos'
  },
  'eventsPage.menuText1': {
    en: 'Available',
    es: 'Disponible'
  },
  'eventsPage.menuText2': {
    en: 'My events',
    es: 'Mis eventos'
  },
  'facebookLoginPage.title': {
    en: 'Facebook login',
    es: 'Entrar con Facebook'
  },
  'facebookLoginPage.contentTitle': {
    en: 'Redirecting...',
    es: 'Redireccionando...'
  },
  'facebookLoginPage.contentDescription': {
    en: 'Just a moment...',
    es: 'Solo un momento...'
  },
  'forumSignaturePage.title': {
    en: 'Forum signature',
    es: 'Firma del foro'
  },
  'groupAddChannelPage.title': {
    en: 'Add channel',
    es: 'Añadir canal'
  },
  'groupChatPage.title': {
    en: 'Group chat',
    es: 'Chat de grupo'
  },
  'groupEditChannelPage.title': {
    en: 'Edit channel',
    es: 'Editar canal'
  },
  'groupInvitePage.title': {
    en: 'Group invite',
    es: 'Invitación de grupo'
  },
  'groupInvitesPage.title': {
    en: 'Group invites',
    es: 'Invitaciones de grupo'
  },
  'groupManageChannelsPage.title': {
    en: 'Manage channels',
    es: 'Administrar canales'
  },
  'groupManageMemberPage.title': {
    en: 'Manage member',
    es: 'Administrar miembro'
  },
  'groupMembersPage.title': {
    en: 'Group members',
    es: 'Miembros del grupo'
  },
  'groupSettingsPage.title': {
    en: 'Group settings',
    es: 'Ajustes de grupo'
  },
  'joinPage.title': {
    en: 'Join',
    es: 'Unirse'
  },
  'newConversationPage.title': {
    en: 'New conversation',
    es: 'Nueva conversación'
  },
  'newGroupPage.title': {
    en: 'New group',
    es: 'Nuevo grupo'
  },
  'newThreadPage.title': {
    en: 'New thread',
    es: 'Nuevo hilo'
  },
  'playersPage.title': {
    en: 'Players',
    es: 'Jugadores'
  },
  'playersPage.playersTop': {
    en: 'Top players',
    es: 'Mejores jugadores'
  },
  'playersPage.playersFollowing': {
    en: 'Following',
    es: 'Partidarios'
  },
  'playersSearchPage.title': {
    en: 'Find player',
    es: 'Encontrar jugador'
  },
  'policiesPage.title': {
    en: 'Policies',
    es: 'Políticas'
  },
  'privacyPage.title': {
    en: 'Privacy',
    es: 'Intimidad'
  },
  'profilePage.title': {
    en: 'Profile'
    es: 'Perfil'
  },
  'profileChestsPage.title': {
    en: 'Chest cycle',
    es: 'Ciclo de cofre'
  },
  'tosPage.title': {
    en: 'Terms of service',
    es: 'Términos de servicio'
  },
  'videosPage.title': {
    en: 'Videos',
    es: 'Videos'
  }
# coffeelint: enable=max_line_length

class Language
  constructor: ({@language}) -> null

  setLanguage: (@language) => null

  get: (strKey, replacements) =>
    baseResponse = strings[strKey]?[@language] or ''

    unless baseResponse
      console.log 'missing', strKey

    if typeof baseResponse is 'object'
      # some languages (czech) have many plural forms
      pluralityCount = replacements[baseResponse.pluralityCheck]
      baseResponse = baseResponse.plurality[pluralityCount] or
                      baseResponse.plurality.other or ''

    _reduce replacements, (str, replace, key) ->
      find = ///__#{key}__///g
      str.replace find, replace
    , baseResponse


module.exports = Language
