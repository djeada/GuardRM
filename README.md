# GuardRM

The idea behind the tool is to create a lightweight, yet robust, safeguard against accidental deletion of critical production data. By intercepting and wrapping the native removal commands (like rm and rmdir), the tool provides a two-tiered defense mechanism—first through an interactive warning that displays the host and target path, and then through a configurable mode where critical directories are strictly protected based on a JSON configuration file. This design ensures that even when operating with elevated privileges (sudo), users are either alerted or blocked from executing potentially disastrous delete commands. The implementation focuses on ease-of-use for out-of-the-box setup, while leaving room for future extensibility to add features like logging, more granular control over deletion policies, and integration with CI/CD pipelines.

![guard_rm](https://github.com/user-attachments/assets/46510f32-0145-42d5-a3e4-16fb84365eb8)
