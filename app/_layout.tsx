import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useColorScheme } from 'react-native';
import { I18nextProvider, useTranslation } from 'react-i18next';
import i18n from '@/i18n';
import Colors from '@/constants/Colors';

function RootStack() {
  const colorScheme = useColorScheme() ?? 'light';
  const { t } = useTranslation();

  return (
    <>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerStyle: { backgroundColor: Colors[colorScheme].cardBackground },
          headerTintColor: Colors[colorScheme].text,
          contentStyle: { backgroundColor: Colors[colorScheme].background },
        }}
      >
        <Stack.Screen
          name="index"
          options={{ title: t('appTitle') }}
        />
      </Stack>
    </>
  );
}

export default function RootLayout() {
  return (
    <I18nextProvider i18n={i18n}>
      <RootStack />
    </I18nextProvider>
  );
}
