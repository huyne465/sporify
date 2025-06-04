import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/core/configs/assets/app_images.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/presentation/root/widgets/new_song.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        hideback: true,
        title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _homeTopArtistCard(),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Text(
                  "Discover New Music",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: context.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              _tabs(),
              SizedBox(
                height: 270, // Adjusted height
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  controller: _tabController,
                  children: [
                    const NewsSongs(),
                    Container(child: Center(child: Text("Coming soon"))),
                    Container(child: Center(child: Text("Coming soon"))),
                    Container(child: Center(child: Text("Coming soon"))),
                  ],
                ),
              ),

              // Add Top Playlists section
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, bottom: 15),
                child: Text(
                  "Popular Artists",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: context.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              // Add placeholder for more content
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.6),
                      AppColors.darkGrey.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "More content coming soon",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeTopArtistCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 140,
      child: Stack(
        children: [
          // Base container with gradient background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.7), Colors.black54],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),

          // SVG background pattern
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SvgPicture.asset(
              AppVectors.artistCard,
              fit: BoxFit.fill,
              width: double.infinity,
            ),
          ),

          // Artist image positioned on top
          Positioned(
            bottom: 0,
            right: 10,
            top: -15, // Move image up to position it on top of the card
            child: Image.asset(
              AppImages.topArtistCard,
              height: 180, // Increased height to make image more prominent
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: context.isDarkMode ? Colors.white : Colors.black,
      unselectedLabelColor: context.isDarkMode
          ? Colors.white60
          : Colors.black45,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      labelPadding: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      tabAlignment: TabAlignment.start,
      tabs: const [
        Tab(text: 'News', height: 35),
        Tab(text: 'Video', height: 35),
        Tab(text: 'Artists', height: 35),
        Tab(text: 'Podcast', height: 35),
      ],
    );
  }
}
