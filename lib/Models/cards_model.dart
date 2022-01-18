import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Utils/duration_format.dart';
import 'package:kiosq_app/Variables/global.dart';

class Cards {
  final String title;
  final DateTime date;
  final String subtitle;
  late bool bigDate;
  final dynamic object;
  Widget? image;
  final String banner;

  Cards(this.title, this.date, this.subtitle, this.object,
      {String? image,
      Widget? forceImage,
      this.bigDate = false,
      this.banner = ""}) {
    this.image = forceImage ??
        CachedNetworkImage(
          width: double.infinity,
          fit: BoxFit.cover,
          height: double.infinity,
          imageUrl: image ?? Global.defaultImageUrl,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              const Icon(Icons.refresh),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
  }

  static Widget cardModel(BuildContext context,
      {bool admin = false,
      bool chats = false,
      Cards? i,
      Function(dynamic)? onPressed}) {
    return GestureDetector(
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Global.colorDim(context),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        margin: const EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
        child: SizedBox(
            child: (admin || chats)
                ? Container(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 65,
                          width: 65,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      (i!.object as Profile).urlPhoto))),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width - 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                chats
                                    ? Text(i.title,
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                                fontWeight: FontWeight.bold))
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text((i.object as Profile).roleStr()),
                                        ],
                                      ),
                                chats
                                    ? Text(
                                        i.subtitle,
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      )
                                    : Text(
                                        i.title,
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        height: 5,
                                        width: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (const Duration(minutes: 2)
                                                      .compareTo(DateTime.now()
                                                          .difference((chats)
                                                              ? (i.object
                                                                      as Profile)
                                                                  .lastUpdate
                                                              : i.date)) >=
                                                  0)
                                              ? Colors.green
                                              : Colors.red,
                                        )),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        lastSeen(i.date,
                                            online: chats
                                                ? Global.str.latest
                                                : "Online"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                                fontStyle: FontStyle.italic)),
                                  ],
                                )
                              ],
                            ))
                      ],
                    ))
                : Stack(children: [
                    i!.image!,
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, 0.1, 0.6, 1]),
                      ),
                    ),
                    Visibility(
                        visible: i.banner.isNotEmpty,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                                child: Center(
                                    child: Text(i.banner,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ]))),
                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Global.marquee(Text(
                              i.title,
                              style: (Theme.of(context).textTheme.headline6)!
                                  .copyWith(color: Colors.white),
                            )),
                            Text(lastSeen(i.date, online: Global.str.latest),
                                style: (Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: Colors.white))),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              i.subtitle,
                              maxLines: 2,
                              style: (Theme.of(context).textTheme.subtitle2)!
                                  .copyWith(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ))
                  ]),
            width: MediaQuery.of(context).size.width),
      ),
      onTap: () => (onPressed) != null ? onPressed.call(i.object) : {},
    );
  }

  static List<Widget> cardItems(List<Cards?> items,
      {required Function(dynamic)? onPressed,
      bool admin = false,
      bool chats = false}) {
    return items.map((i) {
      return Builder(
        builder: (BuildContext context) {
          return cardModel(context,
              admin: admin, chats: chats, i: i, onPressed: onPressed);
        },
      );
    }).toList();
  }

  static Widget getWidgets(BuildContext context,
      {List<Cards>? items,
      bool admin = false,
      bool chats = false,
      String str = "",
      visible = true,
      errorState = false,
      loadingState = false,
      Function()? more,
      Function(dynamic)? onPressed}) {
    return Visibility(
        visible: visible,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Visibility(
              visible: str.isNotEmpty,
              child: Global.defaultPadding(
                  top: 10,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(str),
                        SizedBox(
                            height: 25,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Global.colorDim(context)),
                                    shape: MaterialStateProperty.all(
                                        const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50))))),
                                clipBehavior: Clip.antiAlias,
                                onPressed: more,
                                child: Text(Global.str.more.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ))))
                      ]))),
          Global.defaultPadding(
              horizontal: 0,
              child: (errorState)
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Global.colorDim(context)),
                          height: (admin || chats)
                              ? 120
                              : MediaQuery.of(context).size.height * (6 / 19),
                          child: Center(child: Text(Global.str.error))))
                  : (loadingState)
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 20, right: 20),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Global.colorDim(context)),
                              height: (admin || chats)
                                  ? 120
                                  : MediaQuery.of(context).size.height *
                                      (6 / 19),
                              child: const Center(
                                  child: CircularProgressIndicator())))
                      : (items == null || items.isEmpty)
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 20, right: 20),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Global.colorDim(context)),
                                  height: (admin || chats)
                                      ? 120
                                      : MediaQuery.of(context).size.height *
                                          (6 / 19),
                                  child: Center(child: Text(Global.str.empty))))
                          : (str.isNotEmpty)
                              ? CarouselSlider(
                                  options: CarouselOptions(
                                      autoPlayInterval:
                                          const Duration(seconds: 5),
                                      autoPlayCurve: Curves.easeInOutSine,
                                      viewportFraction: 0.93),
                                  items: cardItems(items,
                                      onPressed: onPressed, chats: chats),
                                )
                              : Column(
                                  children: cardItems(items,
                                          onPressed: onPressed,
                                          admin: admin,
                                          chats: chats)
                                      .map((e) => SizedBox(
                                          height: (admin || chats)
                                              ? 120
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  (9 / 16),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              25,
                                          child: e))
                                      .toList(),
                                )),
        ]));
  }
}
