import Constants from 'expo-constants';
import { Stack } from 'expo-router';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';

import { $api } from '@/lib/api';
import { config } from '@/lib/config';

const appName = Constants.expoConfig?.name ?? 'App';

export default function HomeScreen() {
  const health = $api.useQuery('get', '/healthz');

  return (
    <View style={styles.container}>
      <Stack.Screen options={{ title: appName }} />
      <Text style={styles.title}>{appName}</Text>
      <Text style={styles.muted}>API: {config.apiUrl}</Text>
      {health.isPending ? (
        <ActivityIndicator />
      ) : health.isError ? (
        <Text style={styles.error}>API unreachable</Text>
      ) : (
        <Text style={styles.ok}>
          API {health.data.status} · database {health.data.database} · v{health.data.version}
        </Text>
      )}
      <Pressable accessibilityRole="button" onPress={() => health.refetch()} style={styles.button}>
        <Text style={styles.buttonText}>Check again</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 12, padding: 24 },
  title: { fontSize: 28, fontWeight: '600' },
  muted: { opacity: 0.6 },
  ok: { color: '#1a7f37' },
  error: { color: '#cf222e' },
  button: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    backgroundColor: '#208AEF',
  },
  buttonText: { color: 'white', fontWeight: '600' },
});
