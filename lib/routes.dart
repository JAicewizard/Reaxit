import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/screens/album_screen.dart';
import 'package:reaxit/ui/screens/albums_screen.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/event_admin_screen.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/food_admin_screen.dart';
import 'package:reaxit/ui/screens/food_screen.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/members_screen.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';
import 'package:reaxit/ui/screens/registration_screen.dart';
import 'package:reaxit/ui/screens/settings_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';

final List<GoRoute> routes = [
  GoRoute(path: '/', redirect: (_) => '/welcome'),
  GoRoute(
    path: '/welcome',
    name: 'welcome',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      name: 'Welcome',
      child: WelcomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  ),
  GoRoute(
    path: '/events',
    name: 'calendar',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      name: 'Calendar',
      child: CalendarScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
    routes: [
      GoRoute(
        path: ':eventPk',
        name: 'event',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          name: 'Event(${state.params['eventPk']})',
          child: EventScreen(
            pk: int.parse(state.params['eventPk']!),
            event: state.extra as Event?,
          ),
        ),
        routes: [
          GoRoute(
            path: 'admin',
            name: 'event-admin',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              name: 'EventAdmin(${state.params['eventPk']})',
              child: EventAdminScreen(
                pk: int.parse(state.params['eventPk']!),
              ),
            ),
          ),
          GoRoute(
            path: 'registration',
            name: 'event-registration',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              name: 'Registration(event: ${state.params['eventPk']}, '
                  'registration: ${(state.extra as EventRegistration).pk})',
              child: RegistrationScreen(
                eventPk: int.parse(state.params['eventPk']!),
                registrationPk: (state.extra as EventRegistration).pk,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    // This redirect is above the members route because
    // the members path is a prefix of this albums path.
    path: '/members/photos/:albumSlug',
    redirect: (state) => '/albums/${state.params['albumSlug']}',
  ),
  GoRoute(
    path: '/members',
    name: 'members',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      name: 'Members',
      child: MembersScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
    routes: [
      GoRoute(
        path: 'profile/:memberPk',
        name: 'member',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          name: 'Member(${state.params['memberPk']})',
          child: ProfileScreen(
            pk: int.parse(state.params['memberPk']!),
            member: state.extra as ListMember?,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/albums',
    name: 'albums',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      name: 'Albums',
      child: AlbumsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
    routes: [
      GoRoute(
        path: ':albumSlug',
        name: 'album',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          name: 'Album(${state.params['albumSlug']})',
          child: AlbumScreen(
            slug: state.params['albumSlug']!,
            album: state.extra as ListAlbum?,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/settings',
    name: 'settings',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      name: 'Settings',
      child: SettingsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  ),
  GoRoute(
      path: '/pizzas',
      name: 'food',
      pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            name: 'Food(${(state.extra as Event?)?.foodEvent})',
            child: FoodScreen(
              pk: (state.extra as Event?)?.foodEvent,
              event: state.extra as Event?,
            ),
          ),
      routes: [
        GoRoute(
          path: 'admin',
          name: 'food-admin',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            name: 'FoodAdmin(${state.extra})',
            child: FoodAdminScreen(
              pk: state.extra as int,
            ),
          ),
        ),
      ]),
  GoRoute(
    path: '/login',
    name: 'login',
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      name: 'Login',
      child: const LoginScreen(),
    ),
  ),
];
