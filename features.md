# Features

Note: All features are only tested on Web (Chrome)

1. Language switch (between EN and VN)
2. Login with phone number and password
   1. Session token based (reload page still have session, expire in 30 days)
   2. Session token saved in shared pref for web
3. Register with phone, email, first-last name, password
4. Logout
   1. Remove session token from logal storage and server
5. Light and Dark mode (whole app + setting toggle + server storage)
6. View inbox
   1. Email list preview (subject, body, sender, star icon, time (short - today, yesterday, or full)) + labels
   2. Email list detailed (subject, from , to, cc, bcc, full time, content) + labels
   3. Unread email highlight color
   4. Star/Unstar email
      1. The star is updated immediately
   5. Sender profile
      1. The sender's profile image is displayed in the email preview
      2. Click on the sender's profile pic will show the sender's profile (name, birthdate, bio)
      3. If not, default to first letter + background color
   6. Searching (subject + body keywords) and advanced (time range, keyword, label)
7. View sent (same as inbox)
8. View trash (same as inbox)
9. View starred
   1. Same as others
   2. If unstar, then the email won't disappear immediately, to let user undo
   3. The change is updated in the backend
10. View all (same as inbox)
    1. All mails, including trashed and sent is shown here
11. View email details
    1. Metadata includes
    2. Subject, from, to, rich text body
    3. CC
    4. BCC (only if reader is sender)
    5. Full date time
    6. List of labels
       1. Can add and remove labels of an email (only seen by the receiver)
    7. List of Attachments
       1. Preview attachments
          1. PDF (in browser = open new tab)
          2. Image (jpg, jpeg, png, gif) (in app)
          3. Video (mp4, webm) (in browser = open new tab)
          4. Text (txt) (in app)
       2. Download
    8. Mark read/unread
    9. Mark star/unstar
    10. Mark trash
        1. When in inbox or any folder, the deletion is updated visually going back from email detail
12. Setting
    1. Profile setting
        1. First, last name, email (check if unique), birthdate, bio, profile picture
    2. Auto reply
       1. Toggle, start date, end date, message
    3. Label management
       1. Create, edit and delete label
       2. Edit name and color
    4. Compose mail setting
       1. Font size and font family
       2. (this is only cosmetic, doesn't actually get integrated into the rich text editor)
13. Compose email
    1. To, CC, BCC (support multiple)
    2. Subject, body, attachment
       1. WYSIWYG editor with rich text
       2. Attachment selection and management
14. Display notification
    1. Real time unread counter
    2. Notification screen where you can read the emails by tapping on the notification
    3. Notification read status is saved (The email still need to be manually read/unread)
15. Realtime update inbox list
    1. Email updates in realtime (inbox)
16. Auto answer / auto reply
    1. The sender will receive an auto reply if the recipient has one
    2. If the sender also got one, it won't auto reply on that
17. Answer an email
    1. When viewing an email detail, can reply with quote format
18. Forward an email
    1. Retain source email format, but can't forward attachments
19. Auto save as draft
    1. Local only (no server)
    2. Doesn't save attachments
20. Deploy mobile (it runs on localhost)
21. Phone verification
    1. Doesn't actually affect any features
    2. Due to trial account, only verified numbers can receive the code
22. Change password
    1. Sends a code to the user's actual email. Enter the code in the app and set new password
23. Enable and use 2 steps verification
    1. When the user is logged in and go to setting, they can enable 2fa (no disable)
    2. Upon logging out and logging in, entering the correct login
    3. Sends a 6-character code to the user's real email.
    4. Copy and paste the code into the app to continue to inbox
24. Password recovery
    1. Similar to change password, but the user must enter the email and phone number

## Missing features

1. Spam filter and folder (AI feature, +0.5)
2. Deployment web version (0.5) (must)
3. Teamwork (0.5)
