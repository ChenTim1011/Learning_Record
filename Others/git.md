## Reference

https://gitbook.tw/

## Learn some git command.

## **Remember that Git calculates and generates objects based on the "content of the files." Therefore, simply adding a directory cannot be processed by Git.**

> Note! Empty directories cannot be committed!

## **Tired of Typing or Frequently Mistyping**

Although Git commands aren't long, sometimes you just don't feel like typing them out (e.g., the `checkout` command has 8 letters), or you might often mistype certain commands (e.g., I often type `state` instead of `status`).

In these situations, we can set up some "aliases" in Git to save some keystrokes. Just execute the following in your terminal:

```bash
$ git config --global alias.co checkout
$ git config --global alias.br branch
$ git config --global alias.st status
```

After setting these, typing `git co` will have the same effect as `git checkout`, and `git st` will work like `git status`, saving you many keystrokes.

You can also add some parameters. For example, when viewing logs, you might want to see more concise information, requiring you to type `git log --oneline --graph`, which is quite long. Instead, using an alias:

```bash
$ git config --global alias.l "log --oneline --graph"
```

Now, typing `git l` will give you the same effect as `git log --oneline --graph`:

```bash
$ git l
*   cc200b5 (HEAD -> master) Merge branch 'cat'
|\
| * 0d1d15d (cat) add cat 2
| * 0d392fb add cat 1
|/
* 657fce7 (origin/master, origin/HEAD) add container
* abb4f43 update index page
* cef6e40 create index page
* cc797cd init commit
```

You can even make it more complex by adding more information like commit author and time:

```bash
$ git config --global alias.ls 'log --graph --pretty=format:"%h <%an> %ar %s"'
```

This way, typing `git ls` will display the logs in a more detailed format:

```bash
$ git ls
*   cc200b5 <Eddie Kao> 9 seconds ago Merge branch 'cat'
|\
| * 0d1d15d <Eddie Kao> 18 seconds ago add cat 2
| * 0d392fb <Eddie Kao> 20 seconds ago add cat 1
|/
* 657fce7 <Eddie Kao> 13 days ago add container
* abb4f43 <Eddie Kao> 13 days ago update index page
* cef6e40 <Eddie Kao> 2 weeks ago create index page
* cc797cd <Eddie Kao> 2 weeks ago init commit
```

These alias settings can also be directly edited in the `~/.gitconfig` file:

```bash
[alias]
  co = checkout
  br = branch
  st = status
  l = log --oneline --graph
  ls = log --graph --pretty=format:"%h <%an> %ar %s"
```

Don't underestimate the impact of saving a few keystrokes; the cumulative effect over time can be significant.

### **Let Git Remove Files for You**

Instead of using a two-step process of `rm` to delete a file and then `git add` to stage it, you can directly use the `git rm` command:

```bash
$ git rm welcome.html
rm 'welcome.html'
```

Checking the status:

```bash
$ git status
On branch master
Changes to be committed:
(use "git reset HEAD <file>..." to unstage)

    deleted:    welcome.html
```

The file is already staged, saving you a step.

### **Using the --cached Parameter**

Both the system `rm` and the `git rm` commands will actually delete the file from the working directory. However, if you just want to stop tracking the file without deleting it, use the `--cached` parameter:

```bash
$ git rm welcome.html --cached
rm 'welcome.html'
```

Don't worry, the file is not actually deleted but just removed from Git's tracking. The status will show:

```bash
$ git status
On branch master
Changes to be committed:
(use "git reset HEAD <file>..." to unstage)

    deleted:    welcome.html

Untracked files:
(use "git add <file>..." to include in what will be committed)

    welcome.html
```

### **Rename Files with Git**

Similar to `git rm`, Git provides a command to rename files, saving you an extra step:

```bash
$ git mv hello.html world.html
```

Check the status:

```bash
$ git status
On branch master
Changes to be committed:
(use "git reset HEAD <file>..." to unstage)

    renamed:    hello.html -> world.html
```

### **Git Cares About Content, Not File Names**

Git calculates the SHA-1 value based on the content of the files, so it doesn't care about the file names. When you rename a file, Git doesn't create a new blob object but points to the original one, creating a new tree object because the file name changed.

## **Ignoring a Directory in Git**

To stop tracking a directory or provide a copy without version control history, just remove the `.git` directory:

> If you delete the `.git` directory, Git loses control over this directory, and you cannot recover the project's version history.

### **Search for Specific Words in Commit Messages**

Use the `--grep` parameter to search commit messages:

```bash
$ git log --oneline --grep="WTF"
```

Luckily, none so far!

### **Find Commits with Specific Content**

Use the `-S` parameter to search for commits containing specific content:

```bash
$ git log -S "Ruby"
```

### **Check Commits Within a Specific Time Range**

Use `--since` and `--until` parameters:

```bash
$ git log --oneline --since="9am" --until="12am"
```

To find commits between 9 AM and 12 PM from January 2024:

```bash
$ git log --oneline --since="9am" --until="12am" --after="2024-01"
```

# **What is HEAD?**

HEAD is a pointer to a branch, usually representing the current branch. In the `.git` directory, there is a `HEAD` file:

```bash
$ cat .git/HEAD
ref: refs/heads/master
```

It shows that HEAD is pointing to the `master` branch. The `refs/heads/master` file contains the commit hash:

```bash
$ cat .git/refs/heads/master
e12d8ef0e8b9deae8bf115c5ce51dbc2e09c8904
```

## **Switching Branches**

Assume there are three branches including master:

```bash
$ git branch
cat
dog
* master
```

Switch to the `cat` branch:

```bash
$ git checkout cat
Switched to branch 'cat'
```

Check the HEAD content:

```bash
$ cat .git/HEAD
ref: refs/heads/cat
```

Switch to the `dog` branch:

```bash
$ git checkout dog
Switched to branch 'dog'
```

Check the HEAD content again:

```bash
$ cat .git/HEAD
ref: refs/heads/dog
```

HEAD usually points to the current branch, but if it's not pointing to a branch, it results in a "detached HEAD" state.

# **Excluding Files from Git**

## **Sensitive Files**

To exclude sensitive files like database passwords or AWS keys, or temporary files generated during compilation, use a `.gitignore` file. If it doesn't exist, create it:

```bash
$ touch .gitignore
```

The rules in `.gitignore` apply only to files added after the rules were set. To apply `.gitignore` rules to existing files, remove them from Git's control first:

```bash
$ git rm --cached <file>
```

# **Viewing Commit History of a Specific File**

Use `git log` followed by the file name:

```bash
$ git log welcome.html
commit 688fef0c50004c12fe85aa139e2bf1b1aca4a38f
Author: Eddie Kao <eddie@5xcampus.com>
Date:   Thu Aug 17 03:44:58 2017 +0800

    update welcome

commit cc797cdb7c7a337824a25075e0dbe0bc7c703a1e
Author: Eddie Kao <eddie@5xcampus.com>
Date:   Sun Jul 30 05:04:05 2017 +0800

    init commit
```

To see the changes made in each commit, add the `-p` parameter:

```bash
$ git log -p welcome.html
commit 688fef0c50004c12fe85aa139e2bf1b1aca4a38f
Author: Eddie Kao <eddie@5xruby.tw>
Date:   Thu Aug 17 03:44:58 2017 +0800

    update welcome

diff --git a/welcome.html b/welcome.html
index 94bab17..edc805c 100644
--- a/welcome.html
+++ b/welcome.html
@@ -1 +1,3 @@


hello, git
+
+Welcome to Git

commit cc797cdb7c7a337824a25075e0dbe0bc7c703a1e
Author: Eddie Kao <eddie@5xruby.tw>
Date:   Sun Jul 30 05:04:05 2017 +0800

    init commit

diff --git a/welcome.html b/welcome.html
new file mode 100644
index 0000000..94bab17
--- /dev/null
+++ b/welcome.html
@@ -0,0 +1 @@
+hello, git
```

Lines starting with a `+` are additions, while lines starting with a `-` are deletions.

## **Modifying the Last Commit**

There are several ways to modify commit history:

1. Delete the entire `.git` directory (not recommended).
2. Use `git rebase` to edit history.
3. Use `git reset` to break down commits and recombine them.
4. Use the `--amend` parameter to modify the last commit.

We'll use the 4th method to change the last commit message. If the original log looks like this:

```bash
$ git log --oneline
4879515 WTF
7dbc437 add hello.html
657fce7 add container
abb4f43 update index page
cef6e40 create index page
cc797cd init commit
```

To change the "WTF" message to "Welcome To Facebook":

```bash
$ git commit --amend -m "Welcome To Facebook"
[master 614a90c] Welcome To Facebook
Date: Wed Aug 16 05:42:56 2017 +0800
1 file changed, 0 insertions(+), 0 deletions(-)
create mode 100644 config/database.yml
```

Without the `-m` parameter, it opens a Vim editor for you to edit the message. Now the log looks like this:

# **Who Wrote This Line of Code?**

To find out who wrote a specific line, use `git blame`:

```bash
$ git blame index.html
```

For large files, you can specify a range of lines:

```bash
$ git blame -L 5,10 index.html
```

# **Add a File to the Most Recent Commit**

If you forgot to add a file to your last commit and don't want to make another commit for it:

1. Use `git reset` to break down the last commit, add the new file, and then re-commit.
2. Use the `--amend` parameter.

# **Regret Your Last Commit and Want to Undo It?**

This is common. Although `git reset` seems simple, many misunderstand its meaning.

## **Undoing the Last Commit**

Let's look at the current Git log:

```bash
$ git log --oneline
e12d8ef (HEAD -> master) add database.yml in config folder
85e7e30 add hello
657fce7 add container
abb4f43 update index page
cef6e40 create index page
cc797cd init commit
```

To undo the last commit, you can use relative or absolute methods. The relative method:

```bash
$ git reset e12d8ef^
```

The `^` symbol represents "previous," so `e12d8ef^` means the commit before `e12d8ef`. Two `^` symbols (`e12d8ef^^`) mean two commits before, and so on. Instead of writing many `^`, you can use `~` notation like `e12d8ef~5` for five commits back.

Because `HEAD` and `master` currently point to `e12d8ef`, you can also write:

```bash
$ git reset master^
```

or

```bash
$ git reset HEAD^
```

The absolute method, specifying a specific commit:

```bash
$ git reset 85e7e30
```

This resets to the `85e7e30` commit, which is the one before `e12d8ef`, achieving the same effect.

## **Reset Modes**

`git reset` can be used with three parameters: `--mixed`, `--soft`, and `--hard`, each producing slightly different results.

### **Mixed Mode**

- `--mixed` is the default parameter if none is specified. This mode discards the changes in the staging area but keeps the working directory files unchanged, leaving the files in the working directory but not in the staging area.

### **Soft Mode**

In this mode, neither the working directory nor the staging area files are discarded, so only the HEAD moves. The files remain in the staging area.

### **Hard Mode**

This mode discards both the working directory and the staging area files.

Here’s a summary:

| Mode              | Mixed Mode | Soft Mode | Hard Mode |
| ----------------- | ---------- | --------- | --------- |
| Working Directory | Unchanged  | Unchanged | Discarded |
| Staging Area      | Discarded  | Unchanged | Discarded |

To simplify, the different modes determine "where the files from the commit go":

| Mode                  | Mixed Mode (default)             | Soft Mode                   | Hard Mode     |
| --------------------- | -------------------------------- | --------------------------- | ------------- |
| Files from the commit | Go back to the working directory | Go back to the staging area | Get discarded |
