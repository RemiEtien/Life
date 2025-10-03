import 'package:flutter_test/flutter_test.dart';
import 'package:lifeline/services/sync_service.dart';

void main() {
  group('SyncState Tests', () {
    test('creates state with default values', () {
      const state = SyncState();

      expect(state.pendingJobs, equals(0));
      expect(state.isSyncing, isFalse);
      expect(state.currentStatus, equals('Idle'));
      expect(state.progress, isNull);
    });

    test('creates state with custom values', () {
      const state = SyncState(
        pendingJobs: 5,
        isSyncing: true,
        currentStatus: 'Syncing...',
        progress: 0.5,
      );

      expect(state.pendingJobs, equals(5));
      expect(state.isSyncing, isTrue);
      expect(state.currentStatus, equals('Syncing...'));
      expect(state.progress, equals(0.5));
    });

    group('copyWith Method', () {
      const originalState = SyncState(
        pendingJobs: 3,
        isSyncing: true,
        currentStatus: 'Uploading...',
        progress: 0.25,
      );

      test('returns identical state when no parameters provided', () {
        final copied = originalState.copyWith();

        expect(copied.pendingJobs, equals(originalState.pendingJobs));
        expect(copied.isSyncing, equals(originalState.isSyncing));
        expect(copied.currentStatus, equals(originalState.currentStatus));
        expect(copied.progress, equals(originalState.progress));
      });

      test('updates pendingJobs only', () {
        final updated = originalState.copyWith(pendingJobs: 10);

        expect(updated.pendingJobs, equals(10));
        expect(updated.isSyncing, equals(originalState.isSyncing));
        expect(updated.currentStatus, equals(originalState.currentStatus));
        expect(updated.progress, equals(originalState.progress));
      });

      test('updates isSyncing only', () {
        final updated = originalState.copyWith(isSyncing: false);

        expect(updated.pendingJobs, equals(originalState.pendingJobs));
        expect(updated.isSyncing, isFalse);
        expect(updated.currentStatus, equals(originalState.currentStatus));
        expect(updated.progress, equals(originalState.progress));
      });

      test('updates currentStatus only', () {
        final updated = originalState.copyWith(currentStatus: 'Complete!');

        expect(updated.pendingJobs, equals(originalState.pendingJobs));
        expect(updated.isSyncing, equals(originalState.isSyncing));
        expect(updated.currentStatus, equals('Complete!'));
        expect(updated.progress, equals(originalState.progress));
      });

      test('updates progress only', () {
        final updated = originalState.copyWith(progress: 0.75);

        expect(updated.pendingJobs, equals(originalState.pendingJobs));
        expect(updated.isSyncing, equals(originalState.isSyncing));
        expect(updated.currentStatus, equals(originalState.currentStatus));
        expect(updated.progress, equals(0.75));
      });

      test('updates all fields at once', () {
        final updated = originalState.copyWith(
          pendingJobs: 0,
          isSyncing: false,
          currentStatus: 'Idle',
          progress: 1.0,
        );

        expect(updated.pendingJobs, equals(0));
        expect(updated.isSyncing, isFalse);
        expect(updated.currentStatus, equals('Idle'));
        expect(updated.progress, equals(1.0));
      });

      test('handles null progress correctly', () {
        const stateWithProgress = SyncState(progress: 0.5);
        final updated = stateWithProgress.copyWith(progress: null);

        // Note: copyWith uses ?? operator, so null won't override
        expect(updated.progress, equals(0.5));
      });
    });

    group('SyncState Immutability', () {
      test('is immutable (annotated with @immutable)', () {
        const state1 = SyncState(pendingJobs: 1);
        final state2 = state1.copyWith(pendingJobs: 2);

        expect(state1.pendingJobs, equals(1));
        expect(state2.pendingJobs, equals(2));
        expect(state1, isNot(same(state2)));
      });
    });

    group('SyncState Typical Workflows', () {
      test('idle state', () {
        const idle = SyncState();

        expect(idle.pendingJobs, equals(0));
        expect(idle.isSyncing, isFalse);
        expect(idle.currentStatus, equals('Idle'));
        expect(idle.progress, isNull);
      });

      test('queued state', () {
        const queued = SyncState(
          pendingJobs: 3,
          isSyncing: false,
          currentStatus: 'Queued...',
        );

        expect(queued.pendingJobs, greaterThan(0));
        expect(queued.isSyncing, isFalse);
      });

      test('syncing state with progress', () {
        const syncing = SyncState(
          pendingJobs: 2,
          isSyncing: true,
          currentStatus: 'Uploading photos...',
          progress: 0.3,
        );

        expect(syncing.pendingJobs, greaterThan(0));
        expect(syncing.isSyncing, isTrue);
        expect(syncing.progress, isNotNull);
        expect(syncing.progress, lessThanOrEqualTo(1.0));
        expect(syncing.progress, greaterThanOrEqualTo(0.0));
      });

      test('paused for unlock state', () {
        const paused = SyncState(
          pendingJobs: 5,
          isSyncing: true,
          currentStatus: 'Sync paused - unlock needed',
        );

        expect(paused.pendingJobs, greaterThan(0));
        expect(paused.isSyncing, isTrue);
        expect(paused.currentStatus, contains('unlock'));
      });

      test('sync complete state', () {
        const complete = SyncState(
          pendingJobs: 0,
          isSyncing: false,
          currentStatus: 'Sync complete!',
          progress: 1.0,
        );

        expect(complete.pendingJobs, equals(0));
        expect(complete.isSyncing, isFalse);
        expect(complete.progress, equals(1.0));
      });

      test('sync failed state', () {
        const failed = SyncState(
          pendingJobs: 1,
          isSyncing: false,
          currentStatus: 'Sync failed. Will retry later.',
        );

        expect(failed.isSyncing, isFalse);
        expect(failed.currentStatus, contains('failed'));
      });
    });

    group('Progress Values', () {
      test('progress can be null (indeterminate)', () {
        const state = SyncState(progress: null);
        expect(state.progress, isNull);
      });

      test('progress can be 0.0 (starting)', () {
        const state = SyncState(progress: 0.0);
        expect(state.progress, equals(0.0));
      });

      test('progress can be 1.0 (complete)', () {
        const state = SyncState(progress: 1.0);
        expect(state.progress, equals(1.0));
      });

      test('progress values during upload stages', () {
        // These match the values in _syncMemoryWithRetries
        const uploadingThumbs = SyncState(progress: 0.1);
        const uploadingPhotos = SyncState(progress: 0.3);
        const uploadingVideos = SyncState(progress: 0.6);
        const uploadingAudio = SyncState(progress: 0.8);
        const savingToCloud = SyncState(progress: 0.9);

        expect(uploadingThumbs.progress, equals(0.1));
        expect(uploadingPhotos.progress, equals(0.3));
        expect(uploadingVideos.progress, equals(0.6));
        expect(uploadingAudio.progress, equals(0.8));
        expect(savingToCloud.progress, equals(0.9));
      });
    });

    group('Status Messages', () {
      test('common status messages used in SyncService', () {
        const statusMessages = [
          'Idle',
          'Queued...',
          'Syncing memory...',
          'Uploading thumbnails...',
          'Uploading photos...',
          'Uploading videos...',
          'Uploading audio...',
          'Saving to cloud...',
          'Sync complete!',
          'Sync failed. Will retry later.',
          'Sync paused - unlock needed',
          'Reconciling with cloud...',
        ];

        for (final message in statusMessages) {
          final state = SyncState(currentStatus: message);
          expect(state.currentStatus, equals(message));
        }
      });

      test('status message with retry delay', () {
        const status = 'Sync failed. Retrying in 5s...';
        const state = SyncState(currentStatus: status);

        expect(state.currentStatus, contains('Retrying'));
        expect(state.currentStatus, contains('5s'));
      });
    });

    group('Edge Cases', () {
      test('handles negative pending jobs (should not happen in practice)', () {
        const state = SyncState(pendingJobs: -1);
        expect(state.pendingJobs, equals(-1));
      });

      test('handles progress greater than 1.0', () {
        const state = SyncState(progress: 1.5);
        expect(state.progress, equals(1.5));
      });

      test('handles empty status string', () {
        const state = SyncState(currentStatus: '');
        expect(state.currentStatus, equals(''));
      });

      test('handles very large pending jobs count', () {
        const state = SyncState(pendingJobs: 999999);
        expect(state.pendingJobs, equals(999999));
      });
    });
  });
}
