import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/widgets/music_item.dart';

import 'config/services/remote/api_service.dart';
import 'media.dart';
import 'music_list_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textEditingController = TextEditingController();
  ApiService apiService = ApiService();
  List<Media> mediaList = [];
  bool isLoading = false;
  FocusNode searchFocusNode = FocusNode();

  Color primaryColor = Color(0xffE21221);

  @override
  void initState() {
    searchFocusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicListProvider(),
      child: Consumer<MusicListProvider>(
        builder: (context, MusicListProvider musicListProvider, child) =>
            Scaffold(
          appBar: AppBar(
              backgroundColor: primaryColor,
              title: const Text(
                'Radio Javan Downloader',
                style: TextStyle(fontSize: 18, fontFamily: 'pm'),
              )),
          backgroundColor: const Color(0xffEEEEEE),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          child: AnimatedContainer(
                            height: 54,
                            duration: const Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: searchFocusNode.hasFocus
                                    ? primaryColor
                                    : Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            child: TextField(
                              focusNode: searchFocusNode,
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 14),
                                  hintText: 'Enter music or artist name'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (textEditingController.text.isEmpty) {
                            return;
                          }

                          searchFocusNode.unfocus();
                          mediaList = [];
                          musicListProvider.musicList = [];
                          setState(() {
                            isLoading = true;
                          });

                          musicListProvider.musicList = await apiService
                              .getMusicFromServer(textEditingController.text);

                          setState(() {
                            isLoading = false;
                          });

                          if (musicListProvider.musicList.isNotEmpty) {
                            for (var music in musicListProvider.musicList) {
                              if (mediaList
                                  .where((element) =>
                                      element.artist == music.artist &&
                                      element.song == music.song)
                                  .toList()
                                  .isEmpty) {
                                if (music.type != 'video') {
                                  mediaList.add(
                                    Media(
                                        artist: music.artist,
                                        song: music.song,
                                        photo: music.photo,
                                        audioLink: music.link,
                                        audioFormat: music.type),
                                  );
                                }
                              } else {
                                if (music.type == 'video') {
                                  int itemIndex = mediaList.indexWhere((item) =>
                                      item.artist == music.artist &&
                                      item.song == music.song);
                                  mediaList[itemIndex].videoLink = music.link;
                                  mediaList[itemIndex].videoFormat = 'm3u';
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: isLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Iconsax.search_normal,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (musicListProvider.musicList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 24,
                      ),
                      Text(
                        'Your Music Search',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: Colors.black87, height: 1),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: mediaList.length,
                        itemBuilder: (context, index) {
                          return MusicItem(
                            media: mediaList[index],
                          );
                        }),
                  )
                ],
                Visibility(
                  visible: isLoading,
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Getting Music List...',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
