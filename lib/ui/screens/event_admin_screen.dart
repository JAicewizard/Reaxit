import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

class EventAdminScreen extends StatefulWidget {
  final int pk;

  EventAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  State<EventAdminScreen> createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventAdminCubit(
        RepositoryProvider.of<ApiRepository>(context),
        eventPk: widget.pk,
      )..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: const Text('REGISTRATIONS'),
              actions: [
                const _MarkPresentQrButton(),
                _SearchButton(eventPk: widget.pk),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<EventAdminCubit>(
                  context,
                ).loadRegistrations();
              },
              child: BlocBuilder<EventAdminCubit, EventAdminState>(
                builder: (context, state) {
                  if (state.hasException) {
                    return ErrorScrollView(state.message!);
                  } else if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Scrollbar(
                      child: ListView.separated(
                        key: const PageStorageKey('event-admin'),
                        itemBuilder: (context, index) => _RegistrationTile(
                          registration: state.registrations[index],
                          requiresPayment: state.event!.paymentIsRequired,
                        ),
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: state.registrations.length,
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({
    Key? key,
    required this.eventPk,
  }) : super(key: key);

  final int eventPk;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      icon: const Icon(Icons.search),
      onPressed: () async {
        final adminCubit = BlocProvider.of<EventAdminCubit>(context);
        final searchCubit = EventAdminCubit(
          RepositoryProvider.of<ApiRepository>(context),
          eventPk: eventPk,
        );

        await showSearch(
          context: context,
          delegate: EventAdminSearchDelegate(searchCubit),
        );

        searchCubit.close();

        // After the search dialog closes, refresh the results,
        // since the search screen may have changed stuff through
        // its own EventAdminCubit, that do not show up in the cubit
        // for the EventAdminScreen until a refresh.
        adminCubit.loadRegistrations();
      },
    );
  }
}

class _MarkPresentQrButton extends StatelessWidget {
  const _MarkPresentQrButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<EventAdminCubit>(context);
    return IconButton(
      icon: const Icon(Icons.qr_code),
      tooltip: 'Show presence QR code',
      onPressed: () async {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return SafeArea(
              child: BlocBuilder<EventAdminCubit, EventAdminState>(
                bloc: cubit,
                builder: (context, state) {
                  final theme = Theme.of(context);
                  if (state.event != null) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Scan to mark yourself present.',
                            style: theme.textTheme.subtitle2,
                          ),
                        ),
                        QrImage(
                          data: state.event!.markPresentUrl.toString(),
                          padding: const EdgeInsets.all(24),
                          backgroundColor: Colors.grey[50]!,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: RotatedBox(
                            quarterTurns: 2,
                            child: Text(
                              'Scan to mark yourself present.',
                              style: theme.textTheme.subtitle2,
                            ),
                          ),
                        )
                      ],
                    );
                  } else if (state.isLoading) {
                    return const AspectRatio(
                      aspectRatio: 1,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return AspectRatio(
                      aspectRatio: 1,
                      child: Center(child: Text(state.message!)),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _RegistrationTile extends StatefulWidget {
  final AdminEventRegistration registration;
  final bool requiresPayment;

  _RegistrationTile({
    required this.registration,
    required this.requiresPayment,
  }) : super(key: ValueKey(registration.pk));

  @override
  __RegistrationTileState createState() => __RegistrationTileState();
}

class __RegistrationTileState extends State<_RegistrationTile> {
  late bool present;
  @override
  void initState() {
    super.initState();
    present = widget.registration.present;
  }

  @override
  void didUpdateWidget(covariant _RegistrationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    present = widget.registration.present;
  }

  @override
  Widget build(BuildContext context) {
    final registration = widget.registration;
    final name = registration.member?.fullName ?? registration.name!;

    final presentCheckbox = Checkbox(
      visualDensity: VisualDensity.compact,
      value: present,
      onChanged: (value) async {
        final oldValue = present;
        final messenger = ScaffoldMessenger.of(context);
        try {
          setState(() => present = value!);
          await BlocProvider.of<EventAdminCubit>(context).setPresent(
            registrationPk: registration.pk,
            present: value!,
          );
        } on ApiException {
          setState(() => present = oldValue);
          messenger.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(value!
                ? 'Could not mark $name as present.'
                : 'Could not mark $name as not present.'),
          ));
        }
      },
    );

    late Widget paymentDropdown;
    if (widget.requiresPayment) {
      if (registration.isPaid &&
          registration.payment!.type == PaymentType.tpayPayment) {
        paymentDropdown = DropdownButton<PaymentType?>(
          style: Theme.of(context).textTheme.bodyText2,
          items: const [
            DropdownMenuItem(
              value: PaymentType.tpayPayment,
              child: Text('Thalia Pay'),
            ),
            DropdownMenuItem(
              value: PaymentType.cardPayment,
              child: Text('Card payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.cashPayment,
              child: Text('Cash payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.wirePayment,
              child: Text('Wire payment'),
            ),
            DropdownMenuItem(
              value: null,
              child: Text('Not paid'),
            ),
          ],
          value: registration.payment!.type,
          onChanged: null,
        );
      } else {
        paymentDropdown = DropdownButton<PaymentType?>(
          style: Theme.of(context).textTheme.bodyText2,
          items: const [
            DropdownMenuItem(
              value: PaymentType.cardPayment,
              child: Text('Card payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.cashPayment,
              child: Text('Cash payment'),
            ),
            DropdownMenuItem(
              value: PaymentType.wirePayment,
              child: Text('Wire payment'),
            ),
            DropdownMenuItem(
              value: null,
              child: Text('Not paid'),
            ),
          ],
          value: registration.payment?.type,
          onChanged: (value) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await BlocProvider.of<EventAdminCubit>(context).setPayment(
                registrationPk: registration.pk,
                paymentType: value,
              );
            } on ApiException {
              messenger.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(value != null
                    ? 'Could not mark $name as paid.'
                    : 'Could not mark $name as not paid.'),
              ));
            }
          },
        );
      }
    } else {
      paymentDropdown = const SizedBox.shrink();
    }

    return ListTile(
      horizontalTitleGap: 8,
      title: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Present:',
            style: Theme.of(context).textTheme.caption,
          ),
          presentCheckbox,
          paymentDropdown,
        ],
      ),
    );
  }
}

class EventAdminSearchDelegate extends SearchDelegate {
  final EventAdminCubit _adminCubit;

  EventAdminSearchDelegate(this._adminCubit);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = super.appBarTheme(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        headline6: GoogleFonts.openSans(
          textStyle: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          padding: const EdgeInsets.all(16),
          tooltip: 'Clear search bar',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        )
      ];
    } else {
      return [];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocProvider.value(
      value: _adminCubit..search(query),
      child: BlocBuilder<EventAdminCubit, EventAdminState>(
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else {
            return ListView.separated(
              key: const PageStorageKey('event-admin-search'),
              itemBuilder: (context, index) => _RegistrationTile(
                registration: state.registrations[index],
                requiresPayment: state.event!.paymentIsRequired,
              ),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: state.registrations.length,
            );
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocProvider.value(
      value: _adminCubit..search(query),
      child: BlocBuilder<EventAdminCubit, EventAdminState>(
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else {
            return ListView.separated(
              key: const PageStorageKey('event-admin-search'),
              itemBuilder: (context, index) => _RegistrationTile(
                registration: state.registrations[index],
                requiresPayment: state.event!.paymentIsRequired,
              ),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: state.registrations.length,
            );
          }
        },
      ),
    );
  }
}
