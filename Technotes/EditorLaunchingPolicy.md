#  Editor Launching Policy

_Last updated: Wednesday, 23 September, 2020_

This technote defines the policy for what is loaded in the post editor on app launch.

The app shall always launch to the post editor. Determining what post should be loaded in the editor requires defining the following:

- **Last Draft:** The last post with either a `local` or `edited` status to have been loaded into the post editor. It's important to note that a 
`published` post that is loaded into the post editor and is then changed becomes an `edited` post, and therefore qualifies as a last draft.

The launch policy is as follows:

The app shall launch to the last draft, _except_ when:

- There is no last draft (i.e., on the first launch of the app); or
- The user's actions signal that they are done working with this last draft:
    - The last draft was `published` before quitting the app
    - The user's last action in the app was to leave the post editor (iOS) or deselect any post from the post list (macOS).
 
In these cases, the app shall launch to a new, blank, `local` post.
