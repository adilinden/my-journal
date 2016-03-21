---
layout: post
title: Creating an OverlayFS Patch
date: 2014-01-01 19:38:38
comments: Yes
tags:
  - beaglebone
  - git
  - linux
  - opensource
  - programming

redirect_from:
  - /article/overlayfs-patch/
category:
  - Coding
assets: resources/2014-01-02-overlayfs-patch
---

I've been playing with the Beaglebone and Beaglebone Black once again. To increase the longevity of the SD card media it would make sense to have a read-only root filesystem. While it is not that hard to have a strictly read-only root filesystem, it would be nice to have the features of a union filesystem, where writing is not prohibited, but writes are directed to a dedicated filesystem (such as ramfs or another partition).

Hence the quest for an OverlayFS patch!

Having spent a while looking at a various choices of union filesystems, OverlayFS seems to be most promising as a long term solution. But trying to find a patch for OverlayFS it appears that all development is being done on a git repo, no patches to apply to any kernels.

The OverlayFS patches are in the Github [overlayfs-patches][] repo. Here is how I created the patches.

First clone the linux-stable kernel repo.
{% highlight bash %}
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git linux-overlayfs
{% endhighlight %}

If there is an existing local kernel repo then cloning a shared repo is a space saving option.
{% highlight bash %}
git clone --shared ~/linux-stable linux-overlayfs
{% endhighlight %}

With the Linux kernel stable git repo on hand, fetch the OverlayFS. This will get us all of the OverlayFS branches into our current repository.
{% highlight bash %}
cd linux-overlayfs/
git remote add overlayfs https://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/vfs.git
git fetch overlayfs
{% endhighlight %}

Now that we have the remote branches for OverlayFS available we need to find where the branch of interest started. Let's say we desire to get a patch for the overlayfs/overlayfs.v20 branch. We will need to know where exactly this branch originated on the kernel source tree. Otherwise a diff will get us a lot of changes that are not at all related to OverlayFS. The merge-base command will result in a git object that is the most likely common point, the merge base, of the two branches we specify in the command.
{% highlight bash %}
git merge-base overlayfs/overlayfs.v20 master
4a10c2ac2f368583138b774ca41fac4207911983
{% endhighlight %}

With the git object on hand we can now create the patch file.
{% highlight bash %}
git diff 4a10c2ac2f368583138b774ca41fac4207911983 overlayfs/overlayfs.v20 > overlayfs.v20.patch
{% endhighlight %}

Lastly, the [git-diff(1)][] manual page outlines a single command that is a shortcut for the above 'merge-base' and 'diff' sequence.

> git diff [--options] ... [--] […]
> This form is to view the changes on the branch containing and up to the second , starting at a common ancestor of both . "git diff A...B" is equivalent to "git diff $(git-merge-base A B) B". You can omit any one of , which has the same effect as using HEAD instead.

So we can do this instead.
{% highlight bash %}
git diff master...overlayfs/overlayfs.v20 > overlayfs.v20.patch
{% endhighlight %}

One final step remains, examine the patch to make sure we only have OverlayFS relevant code in there. It would also be nice to see what the base of the patch is in human readable form. Start by examining the log as to where the merge base of the overlayfs/overlayfs.v20 is.
{% highlight bash %}
git show 4a10c2ac2f368583138b774ca41fac4207911983
{% endhighlight %}

Result:
{% highlight bash %}
commit 4a10c2ac2f368583138b774ca41fac4207911983
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Mon Sep 23 15:41:09 2013 -0700

Linux 3.12-rc2

diff --git a/Makefile b/Makefile
index de004ce..8d0668f 100644
--- a/Makefile
+++ b/Makefile
@@ -1,7 +1,7 @@
VERSION = 3
PATCHLEVEL = 12
SUBLEVEL = 0
-EXTRAVERSION = -rc1
+EXTRAVERSION = -rc2
NAME = One Giant Leap for Frogkind

# *DOCUMENTATION*
{% endhighlight %}

Now we know that the base of the overlayfs/overlayfs.v20 branch is the 3.12-rc2 release of the Linux kernel source. With this much more friendly git reference we can now checkout that release and try our new patch.
{% highlight bash %}
git checkout v3.12-rc2
patch -p1 --dry-run < overlayfs.v20.patch
{% endhighlight %}

And the result is:
{% highlight bash %}
patching file Documentation/filesystems/Locking
patching file Documentation/filesystems/overlayfs.txt
patching file Documentation/filesystems/vfs.txt
patching file MAINTAINERS
patching file fs/Kconfig
patching file fs/Makefile
patching file fs/ecryptfs/main.c
patching file fs/internal.h
patching file fs/namei.c
patching file fs/namespace.c
patching file fs/open.c
patching file fs/overlayfs/Kconfig
patching file fs/overlayfs/Makefile
patching file fs/overlayfs/copy_up.c
patching file fs/overlayfs/dir.c
patching file fs/overlayfs/inode.c
patching file fs/overlayfs/overlayfs.h
patching file fs/overlayfs/readdir.c
patching file fs/overlayfs/super.c
patching file fs/splice.c
patching file include/linux/fs.h
patching file include/linux/mount.h
{% endhighlight %}

Without examining the patch in details I would conclude that the patch includes all and only the parts relevant to implement OverlayFS on the v3.12-rc2 Linux kernel release.

[overlayfs-patches]: https://github.com/adilinden/overlayfs-patches
[git-diff(1)]: (https://www.kernel.org/pub/software/scm/git/docs/git-diff.html
