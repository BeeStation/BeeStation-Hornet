
CONTRIBUTING
===

## Table of Contents

1. Introduction
2. Getting Started - Contributing for Dummies
3. Recommended Tools - Creating a Decent Dev Environment
4. Code Standards
5. Codebase-specific Policies
6. Asset Policy
7. Pull Request Standards
8. Banned Content

## 1. Introduction
Hello and welcome to BeeStation's contributing page. You are presumably here because you are interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below; at BeeStation, we strive to maintain code stability and maintainability, and to do that, we need all pull requests to meet our standards. It's in everyone's best interests - including yours!

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as the kinds of powers the team has over your additions, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## 2. Getting Started - Contributing for Dummies

BeeStation doesn't have any kind of design document outlining planned changes; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game.

If you want to contribute the first thing you'll need to do is set up a decent development environment. The default tools for working with BYOND simply aren't sufficient, and the next section explains what we use. We also have a few guides to help you get started with git and making a pull request:

* [Here](https://forums.beestation13.com/t/github-building-the-hive/1334) is a guide for setting up Git and GitKraken.

For beginners, it is strongly recommended you work on small projects like bugfixes or very minor features at first. While we are willing to assist you, we have no desire to write your code for you.

**Please note that you need to credit any code that you port from other codebases.**

There are a variety of ways to give credit, here is a list of our most strongly preferred method to least preferred:
1. Cherry-pick (Guide coming soon). May not always be feasible.
2. Provide a link to the specific pull request(s) in your pull request's description.
3. Mention the codebase it's from in your pull request description.

You can of course, as always, ask for help on our discord.

## 3. Recommended Tools - Creating a Decent Dev Environment

**Important:** Using Dream Maker to write code is not supported and will cause problems. All coding needs to be done in VSCode with the recommended extension(s).

In addition to VSCode, several other tools exist to make your life easier.

* Git client - [GitKraken](https://www.gitkraken.com/) or [Command line (recommended)](https://git-scm.com/downloads)
    * See [Guide to git](https://wiki.beestation13.com/view/Guide_to_git) for more detailed information
* Code editing - [VSCode](https://code.visualstudio.com/) (NOT THE SAME AS VISUAL STUDIO)
* VSCode Extensions - You will be prompted to install this recommended extension automatically: [Goonstation Extension Pack](https://marketplace.visualstudio.com/items?itemName=Goonstation.goonstation-extpack)
* Map editing – Two mapping tools are supported: [StrongDMM](https://github.com/SpaiR/StrongDMM), the most widely used and performant standalone executable, and [FastDMM2](https://fastdmm2.ss13.io/), a browser‑based tool offering more niche controls like selection flipping.
* Icon editing - Dream Maker or your image editor of choice. Any PNG can be imported into Dream Maker.
* Database - MariaDB: [Setup guide](https://wiki.beestation13.com/view/Working_with_the_database#Database_Setup)

## 4. Code Standards
There are a variety of ways you can write valid DM code. However, BeeStation is not as lenient. Maintaining good code standards is important for performance and readability reasons. You can find details about our code standards [here](https://github.com/BeeStation/BeeStation-Hornet/wiki/Code-Standards).

They are mostly the same as /tg/station's code standards, though we are not quite as strict about enforcing them. A notable example is that we don't require our code to be thoroughly documented for autodoc.

Failure to meet these standards can result in your pull request being closed. The code standards are non-exhaustive and Maintainers have the final say.

## 5. Codebase-specific Policies
### CEV-Eris
Sprites from CEV-Eris and sprites clearly inspired by their art style are generally not permitted unless you recolor them using a tolerable color palette.

### HippieStation
HippieStation's code standards are much more lax than BeeStation. Their code typically does not meet our standards. Therefore, you should not attempt to port code from HippieStation unless you have the experience and knowledge necessary to rewrite the code to our standards. Maintainers will not hold your hand for this, instead they will simply close the pull request.

### Goonstation
**Attempting to use Goonstation code without using the steps outlined in this section is grounds for an immediate repoban.**

Goonstation's code license is not compatible with [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.en.html). Therefore, there are very specific steps that need to be taken in order to use Goonstation code:
1. Get approval from a BeeStation Maintainer, explaining specifically what you want to port.
2. Get permission from **EVERY** code author that was involved with writing the code you wish to port.
3. Open the pull request. It must have "[GOON]" at the start of the pull request title. It must say "CONTAINS CODE FROM GOONSTATION" at the top of the pull request description. List **ALL** of the code authors somewhere in your pull request description.
4. Have **EVERY** code author from step two comment on your pull request giving you permission to use the code. The specifics of how they should word their comment can vary on a case-by-case basis.
5. Wait for final approval from a BeeStation Maintainer. This will involve us reaching out to a Goonstation representative for their sign-off.

Failing to correctly follow any step will result in the pull request being closed. If done maliciously, it will also result in a repoban.

## 6. Asset Policy
Assets are things such as art, sprites, sounds, music, etc. Different policies apply depending on where the assets are from, so please look at the relevant subsection.

**If you are the sole creator of the assets and your work is not a derivative, you can ignore the remainder of this section.** Note that by contributing your assets, you are agreeing to license them under [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

**If you are not the sole creator, or if you created a derivative, then regardless of the source, you must give the creator credit in your pull request.**

### Assets from other SS13 servers (other than Goonstation)
Most Space Station 13 servers, with the notable exception of Goonstation, all use the same asset license: [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). However, you always need to double-check. Most asset licenses are mentioned in the codebase's README. Therefore, as long as all assets you are adding are from another SS13 server with the [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) asset license, you shouldn't have to worry as long as you give credit in your pull request.

### Assets from Goonstation
Goonstation uses a similar license, with the exception that their assets cannot be used commercially. All assets from Goonstation should be placed in the `goon` folder, which is licensed under [CC-BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).

### Assets from external (non-SS13) sources
All assets must comply with our asset license, [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). You should always ask the author for permission to use their work.

If you are adding new assets that are not already explicitly licensed under CC-BY-SA 3.0, you must get permission from the author using a very specific process. Them direct messaging you "Sure, you can use it" is not sufficient. You can speak to a Maintainer on Discord for more details.

**Attempting to add assets by falsely claiming it is CC-BY-SA 3.0 is grounds for an immediate repoban. If the offending pull request has been merged, it will immediately be reverted.**

If at any point you are confused or unsure of an asset's license or our policy, ask a Maintainer to help you.

## 7. Pull Request Standards

You should complete the pull-request template in its entirety.

Any pull-request that does not adequately complete the provided template may be closed or marked 'do not merge' by maintainers.
 - Any changes that may affect game balance should be documented as a balance change. This also applies to bug fixes which directly alter the game's balance.
 - Changes must be documented in their entirety including the extent of their effects. (For example, if you change it so all mobs are half speed, don't label the PR as 'monkeys now move twice as slow'). Failing to document the full extent of the changes may result in a repo-ban if the intent of hiding changes is seen as malicious.
 - The section labeled 'about this pull request' should describe the pull request's changes in detail. This includes the changes being made, any important details about how it was implemented, the issues it closes, and links to any other pull requests if code is being ported from another codebase.
 - The section labeled "why it's good for the game" should include the reasons behind the changes and how they will be good for the game.
 - The testing section should contain screenshots, videos, and/or reproducible testing procedures showing that the PR works as specified. Pull-requests that ignore this section, or are not tested, may be closed by maintainers. This applies to small PRs that may seem trivial.
 - The changelog should include a short summary of the changes made. If your pull request includes things made by other people, you should list everybody who contributed, including yourself, after the :cl: tag.
 - Ports should indicate any original code that they have added for the port. This includes highlighting any mass-edit statements done via regex, and any bee specific content that had to be modified to accomodate the changes.

If a pull-request requires updates to the wiki, these changes should be made on your user account page (For example: https://wiki.beestation13.com/view/User:PowerfulBacon), so that the original page can be updated on merge.

## 8. Banned Content

Do not add any of the following in a Pull Request or risk getting the PR closed:

- Any content that violates GitHub Terms of Service.
- Racial or homophobic slurs of any kind.
-  National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
-  Code adding, removing, or updating the availability of alien races/species/human mutants without prior Maintainer approval. Pull requests attempting to add or remove features from said races/species/mutants require prior approval as well.

Just because something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

Violations of the banned content policy can potentially result in a repoban.
