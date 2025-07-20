import type { Plugin } from "@opencode-ai/plugin";
export const NotificationPlugin = async ({ client, $ }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        await $`notify-send "OpenCode" "Session completed!" && notify-send "Done" && paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
      }
    },
  };
};
