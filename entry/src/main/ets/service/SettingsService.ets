import { preferences } from '@kit.ArkData';
import { Constants } from '../common/Constants';

const KEY_SHOW_SUBTITLE: string = 'show_subtitle';

export class SettingsService {
  private static instance: SettingsService | null = null;
  private prefs: preferences.Preferences | null = null;

  static getInstance(): SettingsService {
    if (SettingsService.instance === null) {
      SettingsService.instance = new SettingsService();
    }
    return SettingsService.instance;
  }

  private async getPrefs(): Promise<preferences.Preferences> {
    if (!this.prefs) {
      this.prefs = await preferences.getPreferences(getContext(this), Constants.PREFS_SETTINGS);
    }
    return this.prefs;
  }

  async getShowSubtitle(): Promise<boolean> {
    const prefs = await this.getPrefs();
    return (await prefs.get(KEY_SHOW_SUBTITLE, true)) as boolean;
  }

  async setShowSubtitle(value: boolean): Promise<void> {
    const prefs = await this.getPrefs();
    await prefs.put(KEY_SHOW_SUBTITLE, value);
    await prefs.flush();
  }
}
